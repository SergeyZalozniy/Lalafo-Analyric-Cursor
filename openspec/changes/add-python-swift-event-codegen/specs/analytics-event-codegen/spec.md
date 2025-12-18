## ADDED Requirements

### Requirement: Generate Swift analytics event functions from tabular definitions
The system SHALL generate Swift functions for analytics events based on a structured 7-column CSV input that defines events and their parameters.

#### Scenario: Successful generation from valid tabular file
- **WHEN** a developer provides a valid CSV file that follows the agreed 7-column analytics event schema
- **THEN** the Python generator SHALL produce Swift source files containing functions for each defined event
- **AND** each generated function SHALL have parameters and types that correspond to the event definition in the tabular file.

#### Scenario: Idempotent regeneration
- **WHEN** the generator is run multiple times with the same valid tabular input
- **THEN** the resulting generated Swift files SHALL be stable (no unintended changes beyond formatting)
- **AND** only the intended generated files or regions SHALL be modified.

#### Scenario: Deduplication of duplicate event rows
- **WHEN** the CSV contains multiple identical rows for the same event identity (screen, section, component, element, action, advertisement)
- **THEN** the generator SHALL produce a single Swift function for that identity
- **AND** additional identical rows SHALL be ignored without changing the generated output.

#### Scenario: Warning on conflicting row definitions
- **WHEN** the CSV contains multiple rows that share the same event identity (screen, section, component, element, action, advertisement) but differ in `event_details`
- **THEN** the generator SHALL keep the definition from the first such row
- **AND** SHALL log a warning indicating that later conflicting rows were ignored.

### Requirement: Validate tabular analytics event schema
The system SHALL validate the structure and content of the tabular input before generating Swift code.

#### Scenario: Missing or malformed required columns
- **WHEN** a developer provides a tabular file that is missing required columns (such as event name or parameter type) or has malformed data
- **THEN** the generator SHALL fail with a clear error message
- **AND** no Swift files SHALL be generated or modified.

#### Scenario: Unsupported parameter type
- **WHEN** a tabular definition includes a parameter type that is not mapped to a known Swift type
- **THEN** the generator SHALL report the unsupported type in its output
- **AND** SHALL avoid generating invalid Swift code for that event.

### Requirement: Integrate generated code with existing Swift analytics infrastructure
The system SHALL structure generated Swift code so that it can be used alongside existing analytics code (including `Event` and `EventsTracker` types) without requiring a complete refactor.

#### Scenario: Calling generated event functions from existing tracking layer
- **WHEN** a developer invokes a generated Swift event function from the existing tracking layer
- **THEN** the underlying analytics event SHALL be dispatched using the existing infrastructure
- **AND** the generated function SHALL pass through all declared parameters correctly.


