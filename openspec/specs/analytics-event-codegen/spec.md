# analytics-event-codegen Specification

## Purpose
TBD - created by archiving change add-python-swift-event-codegen. Update Purpose after archive.
## Requirements
### Requirement: Generate Swift analytics event functions from tabular definitions
The system SHALL generate Swift functions for analytics events based on a structured 7-column input that defines events and their parameters, accepting input from **either CSV files or Google Sheets URLs**.

#### Scenario: Successful generation from valid tabular file **or Google Sheets URL**
- **WHEN** a developer provides a valid CSV file **or Google Sheets URL** that follows the agreed 7-column analytics event schema
- **THEN** the Python generator SHALL produce Swift source files containing functions for each defined event
- **AND** each generated function SHALL have parameters and types that correspond to the event definition in the tabular data.

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

### Requirement: Accept Google Sheets URL as input source
The system SHALL accept a Google Sheets URL as an input source in addition to CSV files, enabling users to generate Swift code directly from a live Google Sheets document.

#### Scenario: Generate from publicly accessible Google Sheets URL
- **WHEN** a developer provides a valid Google Sheets URL that is publicly accessible or viewable
- **THEN** the generator SHALL fetch the sheet data in CSV format
- **AND** SHALL process the data using the same 7-column analytics event schema as CSV files
- **AND** SHALL produce identical Swift output to equivalent CSV input.

#### Scenario: Handle Google Sheets URL with specific sheet tab
- **WHEN** a developer provides a Google Sheets URL containing a `gid` parameter to specify a particular sheet tab
- **THEN** the generator SHALL fetch data from the specified tab
- **AND** SHALL process only that tab's data.

#### Scenario: Fail fast on invalid Google Sheets URL
- **WHEN** a developer provides a URL that is not a valid Google Sheets URL
- **THEN** the generator SHALL fail immediately with a clear error message
- **AND** SHALL not attempt to fetch data or generate code.

#### Scenario: Handle permission denied on Google Sheets
- **WHEN** a developer provides a Google Sheets URL that is not publicly accessible and requires authentication
- **THEN** the generator SHALL fail with a clear error message indicating permission issues
- **AND** SHALL suggest ensuring the sheet is publicly accessible or shared appropriately.

#### Scenario: Handle network failures when fetching Google Sheets
- **WHEN** the generator attempts to fetch a Google Sheets URL but encounters a network error (timeout, DNS failure, etc.)
- **THEN** the generator SHALL fail with a clear error message describing the network issue
- **AND** SHALL not generate partial or invalid Swift code.

### Requirement: Maintain backward compatibility with CSV file input
The system SHALL continue to support CSV file input exactly as before, ensuring no breaking changes for existing users.

#### Scenario: Generate from CSV file path (unchanged behavior)
- **WHEN** a developer provides a file path to a CSV file (not a URL)
- **THEN** the generator SHALL process the CSV file using the existing file-based logic
- **AND** SHALL produce Swift code with identical behavior to previous versions.

#### Scenario: Detect input type automatically
- **WHEN** a developer provides an input string via the CLI or UI
- **THEN** the generator SHALL automatically detect whether it is a file path or a Google Sheets URL
- **AND** SHALL route to the appropriate input handler without requiring explicit flags or mode selection.

### Requirement: Support Google Sheets input in macOS UI
The macOS application SHALL provide a user interface for entering Google Sheets URLs in addition to the existing CSV file browser.

#### Scenario: Switch between File and Google Sheets input modes in UI
- **WHEN** a user opens the macOS application
- **THEN** the UI SHALL provide a way to choose between "File" mode and "Google Sheets" mode
- **AND** SHALL display appropriate input controls based on the selected mode (file browser for File mode, text field for Google Sheets mode).

#### Scenario: Enter and validate Google Sheets URL in UI
- **WHEN** a user enters a Google Sheets URL in the macOS application
- **THEN** the UI SHALL pass the URL to the Python generator when the "Generate" button is clicked
- **AND** SHALL display any error messages (invalid URL, network failure, permission denied) in the log output.

#### Scenario: Persist last used input mode and URL
- **WHEN** a user successfully generates code using a Google Sheets URL
- **THEN** the macOS application SHALL persist the URL and input mode (similar to how CSV paths are persisted)
- **AND** SHALL restore the URL and mode when the application is reopened.

