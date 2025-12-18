## 1. Specification and Schema
- [ ] 1.1 Finalize the analytics event schema for tabular input (event name, category, parameters, types, required flags, description).
- [ ] 1.2 Document supported tabular formats (CSV, Excel) and any required column naming conventions.
- [ ] 1.3 Define how events map onto existing Swift types and modules (e.g., `Event`, `EventsTracker`).

## 2. Python Code Generator
- [ ] 2.1 Scaffold a minimal Python project (dependencies, entrypoint script, basic CLI arguments).
- [ ] 2.2 Implement parsing of the tabular event definition files into an internal Python model.
- [ ] 2.3 Implement Swift code generation that produces functions with correct names, parameters, and types based on the internal model.
- [ ] 2.4 Ensure the generator is idempotent and can safely overwrite existing generated Swift files.
- [ ] 2.5 Add basic error reporting for malformed or missing event definitions.

## 3. Swift Integration
- [ ] 3.1 Decide where generated Swift code lives (new file vs. marked regions inside existing files).
- [ ] 3.2 Integrate generated functions with existing Swift analytics infrastructure (`Event.swift`, `EventsTracker.swift`, and related protocols).
- [ ] 3.3 Add examples or sample usage in Swift to demonstrate calling the generated functions.

## 4. Tooling and Developer Experience
- [ ] 4.1 Provide a simple command (e.g., `python -m ...` or `make`/script) to run the generator.
- [ ] 4.2 Document how to add or update an analytics event using the tabular source and regenerate Swift code.
- [ ] 4.3 (Optional) Wire the generator into CI or pre-commit hooks to catch out-of-date generated code.

## 5. Validation and Testing
- [ ] 5.1 Add unit tests for the Python parser and generator logic where appropriate.
- [ ] 5.2 Add tests or checks in Swift (or lightweight smoke tests) to ensure generated functions compile and behave as expected.
- [ ] 5.3 Run `openspec validate add-python-swift-event-codegen --strict` and address any spec or delta issues.


