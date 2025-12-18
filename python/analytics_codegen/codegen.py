from __future__ import annotations

import csv
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple

from .input_source import InputSource


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


def _remove_cyrillic(text: str) -> str:
    """
    Remove Cyrillic characters and clean up the text.

    Args:
        text: Input text that may contain Cyrillic

    Returns:
        Text with Cyrillic removed and cleaned up
    """
    # Remove Cyrillic characters (Ukrainian, Russian, etc.)
    text = re.sub(r'[\u0400-\u04FF]+', ' ', text)
    # Clean up multiple spaces and hyphens
    text = re.sub(r'\s*-\s*', ' ', text)
    text = re.sub(r'\s+', ' ', text)
    return text.strip()


def _split_variants(text: str) -> List[str]:
    """
    Split text into variants if it contains multiple snake_case identifiers.

    Examples:
        "reach_category_advertise_button" -> ["reach_category_advertise_button"]
        "reach_category_advertise_button reach_category_after_posting" ->
            ["reach_category_advertise_button", "reach_category_after_posting"]

    Args:
        text: Input text potentially containing multiple variants

    Returns:
        List of variant strings
    """
    # First, remove Cyrillic text
    cleaned = _remove_cyrillic(text)

    # Split by whitespace
    parts = cleaned.split()

    # Filter out empty strings and very short words (likely artifacts)
    variants = [p.strip() for p in parts if p.strip() and len(p.strip()) > 2]

    # If no valid variants found, return the original cleaned text
    if not variants:
        return [cleaned] if cleaned else [text]

    return variants


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


def _parse_csv_rows(csv_rows: List[List[str]]) -> List[EventRow]:
    """
    Parse CSV rows into EventRow objects.

    Supports two formats:
    1. With header row: Detects columns by name (screen:, component:, etc.)
    2. Without header row: Uses positional columns (legacy format)

    Args:
        csv_rows: List of CSV rows (each row is a list of strings)

    Returns:
        List of EventRow objects
    """
    if not csv_rows:
        return []

    rows: List[EventRow] = []

    # Check if first row is a header row by looking for column names with colons
    first_row = csv_rows[0] if csv_rows else []
    is_header_row = any(
        col.strip().lower() in ["screen:", "component:", "section:", "element:", "action:", "event_details"]
        for col in first_row
    )

    # If header row exists, find column indices
    column_map = {}
    start_idx = 0

    if is_header_row:
        start_idx = 1  # Skip header row
        for idx, col_name in enumerate(first_row):
            col_lower = col_name.strip().lower()
            if col_lower == "screen:":
                column_map["screen"] = idx
            elif col_lower == "component:":
                column_map["component"] = idx
            elif col_lower == "section:":
                column_map["section"] = idx
            elif col_lower == "element:":
                column_map["element"] = idx
            elif col_lower == "action:":
                column_map["action"] = idx
            elif col_lower == "event_details":
                column_map["event_details"] = idx
            elif "advertisement" in col_lower:
                column_map["advertisement"] = idx

    # Process data rows
    for raw_row in csv_rows[start_idx:]:
        # Skip empty lines
        if not raw_row or all(not c.strip() for c in raw_row):
            continue

        # Extract values based on header mapping or positional
        if column_map:
            # Use header-based mapping
            screen = raw_row[column_map["screen"]].strip() if "screen" in column_map and column_map["screen"] < len(raw_row) else ""
            section = raw_row[column_map["section"]].strip() if "section" in column_map and column_map["section"] < len(raw_row) else ""
            component = raw_row[column_map["component"]].strip() if "component" in column_map and column_map["component"] < len(raw_row) else ""
            element = raw_row[column_map["element"]].strip() if "element" in column_map and column_map["element"] < len(raw_row) else ""
            action = raw_row[column_map["action"]].strip() if "action" in column_map and column_map["action"] < len(raw_row) else ""
            event_details = raw_row[column_map["event_details"]].strip() if "event_details" in column_map and column_map["event_details"] < len(raw_row) else ""
            advertisement = raw_row[column_map["advertisement"]].strip() if "advertisement" in column_map and column_map["advertisement"] < len(raw_row) else ""
        else:
            # Legacy positional format (backward compatibility)
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

        # Check if section contains multiple variants
        section_variants = _split_variants(section)

        # Create an event row for each section variant
        for section_variant in section_variants:
            if not section_variant:
                continue

            rows.append(
                EventRow(
                    screen=screen,
                    section=section_variant,
                    component=component,
                    element=element,
                    action=action,
                    event_details=event_details,
                    advertisement=advertisement,
                )
            )
    return rows


def _parse_csv(path: Path) -> List[EventRow]:
    """
    Parse CSV file into EventRow objects.

    Args:
        path: Path to CSV file

    Returns:
        List of EventRow objects

    Raises:
        FileNotFoundError: If file doesn't exist
    """
    if not path.is_file():
        raise FileNotFoundError(f"Input file not found: {path}")

    csv_rows: List[List[str]] = []
    with path.open("r", encoding="utf-8", newline="") as f:
        reader = csv.reader(f)
        for raw_row in reader:
            csv_rows.append(raw_row)

    return _parse_csv_rows(csv_rows)


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


def generate_swift_from_input(
    input_source: InputSource,
    output_path: Path,
) -> int:
    """
    Load analytics events from an input source and write Swift tracking functions.

    Args:
        input_source: InputSource (CSV file or Google Sheets)
        output_path: Path to output Swift file

    Returns:
        Number of functions generated

    Raises:
        FileNotFoundError: If input source is not accessible
        ValueError: If input data is invalid
    """
    csv_rows = input_source.get_csv_rows()
    rows = _parse_csv_rows(csv_rows)
    rows = _deduplicate(rows)

    lines: List[str] = ["// Auto-generated tracking functions", ""]

    count = 0
    for row in rows:
        lines.append(_generate_function(row))
        count += 1

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

    return count


def generate_swift_from_csv(
    input_path: Path,
    output_path: Path,
) -> int:
    """
    Load analytics events from CSV and write Swift tracking functions.

    This function is kept for backward compatibility.
    New code should use generate_swift_from_input with FileInputSource.

    Args:
        input_path: Path to CSV file
        output_path: Path to output Swift file

    Returns:
        Number of functions generated

    Raises:
        FileNotFoundError: If CSV file doesn't exist
        ValueError: If CSV data is invalid
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


