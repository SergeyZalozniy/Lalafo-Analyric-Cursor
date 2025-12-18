# Change: Python tool to generate Swift analytics event functions from tabular specs

## Why
Manual maintenance of Swift analytics event functions is error-prone and slow, especially when the source of truth for events lives in spreadsheets (Excel, CSV, or similar tabular formats). A Python-based generator can ingest these tabular event definitions and reliably emit Swift functions with the correct names, parameters, and types, reducing drift and simplifying updates.

## What Changes
- Introduce a Python project that reads analytics event definitions from tabular files (e.g., CSV or Excel) and generates Swift code.
- Define a clear schema for event definitions (event name, category, parameters, types, and any required metadata) that the generator will expect.
- Generate Swift functions that map 1:1 to defined events, with strongly typed parameters matching the tabular schema.
- Ensure the generator is idempotent and safe to run repeatedly, updating only the intended Swift files or regions.
- Integrate the generator with the existing Swift analytics codebase so the generated functions can be used from `Event.swift`, `EventsTracker.swift`, and related files.

## Impact
- Affected specs: `analytics-event-codegen`
- Affected code: Swift event definitions and tracking utilities (e.g., `Swift/Event.swift`, `Swift/EventsTracker.swift`), new Python tooling and configuration files.


