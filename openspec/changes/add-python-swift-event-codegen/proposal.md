# Change: Python tool to generate Swift analytics event functions from tabular specs

## Why
Manual maintenance of Swift analytics event functions is error-prone and slow, especially when the source of truth for events lives in spreadsheets (Excel, CSV, or similar tabular formats). A Python-based generator can ingest these tabular event definitions and reliably emit Swift functions with the correct names, parameters, and types, reducing drift and simplifying updates.

## What Changes
- Introduce a Python project that reads analytics event definitions from CSV files using a fixed 7-column schema and generates Swift code.
- Define and document the event schema based on the existing `analytics.csv` format (screen, section, component, element, action, event_details, advertisement).
- Generate Swift functions that map 1:1 to unique event identities (screen, section, component, element, action, advertisement), with strongly typed parameters matching the schema and current Swift enums.
- Implement deterministic generation with deduplication rules (conflicting rows with the same identity are resolved by keeping the first and warning about the rest).
- Provide a small macOS SwiftUI app that wraps the generator with a CSV picker, output path picker, and log view, including a platform segmented control (android, ios, web, web-mobile) initially locked to `ios`.
- Persist previously selected file paths so that the UI is pre-populated on next launch.
- Ensure the generator is idempotent and safe to run repeatedly, updating only the intended generated Swift file(s).
- Integrate the generator with the existing Swift analytics codebase so the generated functions can be used from `Event.swift`, `EventsTracker.swift`, and related files.

## Impact
- Affected specs: `analytics-event-codegen`
- Affected code: Swift event definitions and tracking utilities (e.g., `Swift/Event.swift`, `Swift/EventsTracker.swift`), new Python tooling and configuration files.


