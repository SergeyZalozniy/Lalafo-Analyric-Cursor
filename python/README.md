## Analytics Swift Tracking Codegen (Python)

This Python tool generates **Swift analytics tracking functions** from a CSV file
using the same 7-column schema as your existing `generate_tracking.swift` script.

### CSV schema

The generator expects exactly this layout (no `event_key` column):

| Column # | Name            | Required | Description |
|----------|-----------------|----------|-------------|
| 1        | `screen`        | ✅       | Event screen name (`Event.Screen`) |
| 2        | `section`       | ✅       | Event section name (`Event.Section`) |
| 3        | `component`     | ✅       | Component name (`Event.Component`) |
| 4        | `element`       | ✅       | UI element name (`Event.Element`) |
| 5        | `action`        | ✅       | Event action (e.g. `tap`, `view`, `error`; `Event.Action`) |
| 6        | `event_details` | ❌       | Optional dynamic event details; if non-empty, adds `parameters: [EventDetailsParameter]` and `details: .defined(parameters)` |
| 7        | `advertisement` | ❌       | Optional; if non-empty, adds `advertisement: EventAdvertisementProtocol` and uses `EventFactory.event(for:with:)` |

Function identity (for deduplication) is the tuple:
`(screen, section, component, element, action, advertisement)`.

- If two rows share this identity and `event_details` is the same → treated as duplicates; only one function is generated.
- If `event_details` differs for the same identity → the **first** row wins; later conflicting rows are **ignored**, and a warning is printed to stderr so you can clean up the CSV if needed.

### Usage

From the repository root:

```bash
python -m python.analytics_codegen.cli \
  --input /absolute/path/to/analytics.csv \
  --output Swift/GeneratedTrackingFunctions.swift
```

Defaults (if flags are omitted):

- `--input`: `analytics.csv` (relative to current directory)
- `--output`: `Swift/GeneratedTrackingFunctions.swift` (relative to project root)

### Behavior

- Uses the same naming rules as the Swift script:
  - `track` + PascalCase of `screen`, `section`, `component`, `element`, `action`,
    where parameterized fields (containing `"|"`) contribute their **field type**
    (e.g., `Component`) to the function name.
- Parameterization:
  - If a column contains `"|"`, that axis becomes a function parameter
    (e.g., `component: Event.Component`), and the corresponding enum value is
    taken from the call site.
  - Otherwise the axis is emitted as a concrete enum literal
    (e.g., `Event.Component.post`).
- If `event_details` is non-empty, the generator adds a
  `parameters: [EventDetailsParameter]` argument and sets
  `details: .defined(parameters)` in `EventDetails`.
- If `advertisement` is non-empty, the generator:
  - Adds `advertisement: EventAdvertisementProtocol` as the first parameter.
  - Uses `EventFactory.event(for: advertisement, with: eventDetails)` instead of
    `EventFactory.event(with: eventDetails)`.


