## Context
This change introduces a Python-based code generator that reads analytics event definitions from tabular sources (such as CSV or Excel) and produces Swift functions used for tracking events in the existing analytics system. The current Swift code for events is maintained manually, which makes it easy for the implementation to drift from the source of truth maintained in spreadsheets.

## Goals / Non-Goals
- Goals:
  - Automate generation of Swift analytics event functions from a well-defined tabular schema.
  - Keep the generator simple, reproducible, and easy to run locally.
  - Cleanly integrate generated functions into the existing Swift analytics codebase without requiring a large refactor.
- Non-Goals:
  - Building a fully generic multi-language code generator.
  - Redesigning the overall analytics architecture or transport pipeline.
  - Changing the runtime behavior of event dispatch beyond what is needed to call generated functions.

## Decisions
- Decision: Use Python for the generator because it has strong support for CSV/Excel parsing, templating, and scripting, and is already acceptable in this project.
- Decision: Represent events in a single, explicit tabular schema (columns for event name, category, parameter name, type, required flag, description) rather than loosely interpreted sheets.
- Decision: Generate Swift code into a dedicated file or small set of files (e.g., `GeneratedEvents.swift`) to avoid overwriting hand-written logic and to keep code review focused.
- Decision: Structure generated Swift so that each event becomes a well-typed function with parameters mapped from the schema, and ensure these functions are easy to call from existing types such as `Event` or `EventsTracker`.

## Risks / Trade-offs
- Risk: Schema changes in the spreadsheets (renamed columns, new types) can break the generator if not coordinated.
  - Mitigation: Document the schema clearly, add validation of input files, and provide meaningful error messages.
- Risk: Over-reliance on generated code might hide complexity or make debugging harder.
  - Mitigation: Keep generation templates straightforward, keep generated files readable, and avoid unnecessary abstraction.
- Trade-off: Using a separate Python project adds another tool to the stack.
  - Mitigation: Keep the Python dependencies minimal and provide simple commands and documentation for running the tool.

## Migration Plan
1. Define and validate the tabular schema against a small sample of existing analytics events.
2. Implement the Python generator and produce a first version of generated Swift code into a new file.
3. Update or create Swift call sites to use the generated functions for a subset of events.
4. Gradually migrate additional events to the new flow as confidence grows.
5. Once the pattern is proven, standardize on using the generator as the primary way to add or update events.

## Open Questions
- How closely should generated functions align with any existing `Event` or `EventsTracker` abstractions (e.g., static helpers vs. instance methods)?
- Which exact tabular formats (CSV only vs. CSV + Excel) are required for the first iteration?
- Should the generator support multiple environments or platforms (e.g., iOS only vs. shared code for multiple Apple platforms)?


