from __future__ import annotations

import csv
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple


@dataclass(frozen=True)
class EventRow:
    screen: str
    section: str
    component: str
    element: str
    action: str
    event_details: str = ""
    advertisement: str = ""


def _camel_case(value: str) -> str:
    parts = [p for p in value.strip().split("_") if p]
    if not parts:
        return value
    first, *rest = parts
    return first.lower() + "".join(p.capitalize() for p in rest)


def _pascal_case(value: str) -> str:
    return "".join(p.capitalize() for p in value.strip().split("_") if p)


def _process_field(
    value: str,
    field_type: str,
    params: List[str],
) -> Tuple[str, Optional[str]]:
    """
    Mirrors Swift `processField`:
    - If value contains '|', treat field as parameter:
      - add `<field_type.lower()>: Event.<FieldType>` to params
      - return (param_name, field_type)
    - Otherwise:
      - return ("Event.<FieldType>.<camelCase(value)>", None)
    """
    value = value.strip()
    if "|" in value:
        param_name = field_type.lower()
        params.append(f"{param_name}: Event.{field_type}")
        return param_name, field_type
    return f"Event.{field_type}.{_camel_case(value)}", None


def _generate_function(row: EventRow) -> str:
    params: List[str] = []

    has_advertisement = bool(row.advertisement.strip())
    if has_advertisement:
        params.insert(0, "advertisement: EventAdvertisementProtocol")

    screen_val, screen_type = _process_field(row.screen, "Screen", params)
    section_val, section_type = _process_field(row.section, "Section", params)
    component_val, component_type = _process_field(row.component, "Component", params)
    element_val, element_type = _process_field(row.element, "Element", params)
    action_val, action_type = _process_field(row.action, "Action", params)

    has_event_details_param = bool(row.event_details.strip())
    if has_event_details_param:
        params.append("parameters: [EventDetailsParameter]")

    func_name_parts = [
        "track",
        _pascal_case(screen_type or row.screen),
        _pascal_case(section_type or row.section),
        _pascal_case(component_type or row.component),
        _pascal_case(element_type or row.element),
        _pascal_case(action_type or row.action),
    ]
    func_name = "".join(func_name_parts)

    params_str = "()" if not params else f"({', '.join(params)})"

    event_details_lines = [
        f"screen: {screen_val}",
        f"section: {section_val}",
        f"component: {component_val}",
        f"element: {element_val}",
        f"action: {action_val}",
    ]
    if has_event_details_param:
        event_details_lines.append("details: .defined(parameters)")

    lines: List[str] = []
    lines.append(f"static func {func_name}{params_str} " + "{")
    lines.append("    let eventDetails: EventDetails = EventDetails(")
    for i, line in enumerate(event_details_lines):
        comma = "" if i == len(event_details_lines) - 1 else ","
        lines.append(f"        {line}{comma}")
    lines.append("    )")
    if has_advertisement:
        lines.append(
            "    let event: EventModel = "
            "EventFactory.event(for: advertisement, with: eventDetails)"
        )
    else:
        lines.append(
            "    let event: EventModel = "
            "EventFactory.event(with: eventDetails)"
        )
    lines.append("    trackEvent(event: event)")
    lines.append("}")
    lines.append("")  # blank line between functions

    return "\n".join(lines)


def _parse_csv(path: Path) -> List[EventRow]:
    if not path.is_file():
        raise FileNotFoundError(f"Input file not found: {path}")

    rows: List[EventRow] = []
    with path.open("r", encoding="utf-8", newline="") as f:
        reader = csv.reader(f)
        for raw_row in reader:
            # Skip empty lines
            if not raw_row or all(not c.strip() for c in raw_row):
                continue

            # We expect at least 5 columns (screen..action)
            if len(raw_row) < 5:
                continue

            # Pad to 7 columns to simplify indexing
            while len(raw_row) < 7:
                raw_row.append("")

            screen = raw_row[0].strip()
            section = raw_row[1].strip()
            component = raw_row[2].strip()
            element = raw_row[3].strip()
            action = raw_row[4].strip()
            event_details = raw_row[5].strip()
            advertisement = raw_row[6].strip()

            # Basic required columns check
            if not (screen and section and component and element and action):
                continue

            rows.append(
                EventRow(
                    screen=screen,
                    section=section,
                    component=component,
                    element=element,
                    action=action,
                    event_details=event_details,
                    advertisement=advertisement,
                )
            )
    return rows


def _deduplicate(rows: Iterable[EventRow]) -> List[EventRow]:
    """
    Deduplicate based on (screen, section, component, element, action, advertisement).
    If two rows share this identity:
    - If event_details is the same → keep the first, drop duplicates silently.
    - If event_details differs → keep the first, drop the rest with a warning.
    """
    import sys

    by_key: Dict[Tuple[str, str, str, str, str, str], EventRow] = {}

    for row in rows:
        key = (
            row.screen,
            row.section,
            row.component,
            row.element,
            row.action,
            row.advertisement,
        )
        existing = by_key.get(key)
        if existing is None:
            by_key[key] = row
            continue

        # Same identity; check details consistency
        if existing.event_details == row.event_details:
            # Exact duplicate – ignore silently
            continue

        # Conflicting definitions: keep the first, warn about the later ones
        print(
            "⚠️ Conflicting rows for analytics event "
            f"(screen={row.screen}, section={row.section}, "
            f"component={row.component}, element={row.element}, "
            f"action={row.action}, advertisement={row.advertisement}). "
            "Using the first definition and ignoring this row "
            "(event_details differ).",
            file=sys.stderr,
        )

    return list(by_key.values())


def generate_swift_from_csv(
    input_path: Path,
    output_path: Path,
) -> int:
    """
    Load analytics events from CSV and write Swift tracking functions.

    Returns the number of functions generated.
    """
    rows = _parse_csv(input_path)
    rows = _deduplicate(rows)

    lines: List[str] = ["// Auto-generated tracking functions", ""]

    count = 0
    for row in rows:
        lines.append(_generate_function(row))
        count += 1

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

    return count


