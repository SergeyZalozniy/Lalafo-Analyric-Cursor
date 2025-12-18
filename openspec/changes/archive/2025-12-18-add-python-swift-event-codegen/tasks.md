## 1. Specification and Schema
- [x] 1.1 Finalize the analytics event schema for tabular input (event name, category, parameters, types, required flags, description).
- [x] 1.2 Document supported tabular formats (CSV, Excel) and any required column naming conventions.
- [x] 1.3 Define how events map onto existing Swift types and modules (e.g., `Event`, `EventsTracker`).

## 2. Python Code Generator
- [x] 2.1 Scaffold a minimal Python project (dependencies, entrypoint script, basic CLI arguments).
- [x] 2.2 Implement parsing of the 7-column CSV event definition files into an internal Python model using the standard `csv` module (including quoted fields and newlines).
- [x] 2.3 Implement Swift code generation that produces functions with correct names, parameters, and types based on the internal model, mirroring the existing `generate_tracking.swift` behavior.
- [x] 2.4 Implement deduplication rules: treat identical rows as duplicates and keep only the first; when rows share the same identity but differ in `event_details`, keep the first and log a warning.
- [x] 2.5 Ensure the generator is idempotent and can safely overwrite existing generated Swift files.
- [x] 2.6 Add basic error reporting for malformed or missing event definitions.

## 3. Swift Integration
- [x] 3.1 Decide where generated Swift code lives (new file vs. marked regions inside existing files).
- [x] 3.2 Integrate generated functions with existing Swift analytics infrastructure (`Event.swift`, `EventsTracker.swift`, and related protocols).
- [x] 3.3 Add examples or sample usage in Swift to demonstrate calling the generated functions.

## 4. Tooling and Developer Experience
- [x] 4.1 Provide a simple command (e.g., `python -m ...` or `make`/script) to run the generator.
- [x] 4.2 Implement a standalone macOS SwiftUI app that wraps the generator with:
  - [x] CSV file picker
  - [x] Output Swift path picker
  - [x] Platform segmented control with options `android`, `ios`, `web`, `web-mobile`, initially locked to `ios`
  - [x] Log area for stdout/stderr from the generator
- [x] 4.3 Persist last-used CSV and output paths using a small preferences manager so they are restored on launch.
- [x] 4.4 Document how to add or update an analytics event using the tabular source, regenerate Swift code from the CLI, and use the macOS UI.
<!-- - [ ] 4.5 (Optional) Wire the generator into CI or pre-commit hooks to catch out-of-date generated code. -->

## 5. Validation and Testing
- [x] 5.1 Add unit tests for the Python parser and generator logic where appropriate.
- [x] 5.2 Add tests or checks in Swift (or lightweight smoke tests) to ensure generated functions compile and behave as expected.
- [x] 5.3 Run `openspec validate add-python-swift-event-codegen --strict` and address any spec or delta issues.


