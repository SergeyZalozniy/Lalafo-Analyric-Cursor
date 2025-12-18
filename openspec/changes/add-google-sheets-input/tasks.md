# Implementation Tasks: Add Google Sheets Input Support

## Phase 1: Core Python Implementation

### Task 1.1: Add Google Sheets URL detection and validation
- [x] Implement `detect_input_type(input_str: str) -> InputType` to distinguish file paths from URLs
- [x] Add `InputType` enum with `CSV_FILE` and `GOOGLE_SHEETS` values
- [x] Implement URL validation to ensure only `https://docs.google.com/spreadsheets/*` URLs are accepted
- [x] Add unit tests for URL detection with various valid and invalid inputs
- **Validation**: Unit tests pass; invalid URLs are rejected with clear error messages

### Task 1.2: Implement Google Sheets data fetcher
- [x] Create `GoogleSheetsInputSource` class with methods to:
  - Extract spreadsheet ID from URL
  - Extract optional `gid` (sheet tab identifier) from URL
  - Build CSV export URL format: `https://docs.google.com/spreadsheets/d/{ID}/export?format=csv&gid={GID}`
- [x] Implement HTTP fetching using `urllib.request` or `requests` library
- [x] Handle HTTP errors (404, 403, network timeout) with descriptive error messages
- [x] Add unit tests mocking HTTP responses (success, 404, 403, timeout)
- **Validation**: Unit tests pass; error messages are clear and actionable

### Task 1.3: Create input source abstraction
- [x] Create `InputSource` abstract base class with `get_csv_rows() -> List[List[str]]` method
- [x] Implement `FileInputSource` class wrapping existing CSV file reading logic
- [x] Implement `GoogleSheetsInputSource` class using fetcher from Task 1.2
- [x] Refactor `_parse_csv(path: Path)` into `_parse_csv_rows(rows: List[List[str]])` to work with abstraction
- [x] Add tests for both `FileInputSource` and `GoogleSheetsInputSource`
- **Validation**: Both input sources produce identical parsed `EventRow` objects from equivalent data

### Task 1.4: Update CLI to support Google Sheets URLs
- [x] Update `cli.py` to detect input type using `detect_input_type`
- [x] Create appropriate `InputSource` based on detected type
- [x] Update `--input` argument help text to mention Google Sheets URL support
- [x] Update error handling to cover Google Sheets-specific errors (network, permissions)
- [x] Add integration test using a real public Google Sheet (or mock HTTP response)
- **Validation**: CLI can generate Swift code from both CSV files and Google Sheets URLs; error messages are clear

### Task 1.5: Add Python dependencies (if needed)
- [x] Evaluate if `requests` library is needed or if `urllib.request` (built-in) is sufficient
- [x] Update `requirements.txt` or `requirements-dev.txt` if new dependencies are added
- [x] Document any new dependencies in README
- **Validation**: `pip install -r requirements.txt` succeeds; all tests pass (used built-in urllib.request)

### Task 1.6: Update Python README with Google Sheets usage
- [x] Add section documenting Google Sheets URL support
- [x] Provide example command: `python -m analytics_codegen.cli --input "https://docs.google.com/spreadsheets/d/SHEET_ID" --output Output.swift`
- [x] Document how to make a Google Sheet publicly accessible
- [x] Document how to specify a particular sheet tab using `gid` parameter
- [x] Add troubleshooting section for common errors (403, 404, network)
- **Validation**: README is clear and actionable

## Phase 2: macOS UI Implementation

### Task 2.1: Add input mode toggle to ContentView
- [x] Create `InputMode` enum with cases `.file` and `.googleSheets`
- [x] Add `@State var inputMode: InputMode = .file` to `ContentView`
- [x] Add `Picker` or `SegmentedControl` to toggle between File and Google Sheets modes
- [x] Conditionally display CSV file browser (File mode) or URL text field (Google Sheets mode)
- **Validation**: UI displays correct input controls based on selected mode

### Task 2.2: Add Google Sheets URL text field
- [x] Add `@State var googleSheetsURL: String = ""` to `ContentView`
- [x] Add `TextField` for Google Sheets URL input (visible only in Google Sheets mode)
- [x] Add basic URL validation in the UI (non-empty, starts with `https://`)
- [x] Disable "Generate" button if Google Sheets mode is selected and URL is empty/invalid
- **Validation**: User can enter a URL; "Generate" button state reflects input validity

### Task 2.3: Update PythonRunner to pass Google Sheets URL
- [x] Modify `runPythonGenerator` to accept input mode and URL/path
- [x] Pass `--input <url>` to Python CLI when Google Sheets mode is selected
- [x] Pass `--input <file_path>` to Python CLI when File mode is selected (unchanged)
- **Validation**: Python CLI is invoked with correct input parameter based on UI mode

### Task 2.4: Persist Google Sheets URL and input mode
- [x] Extend `PathPreferences` to store and load `inputMode` and `googleSheetsURL`
- [x] Load last used input mode and URL on app launch (similar to CSV/output paths)
- [x] Store input mode and URL when "Generate" succeeds
- **Validation**: Input mode and URL are restored after app restart

### Task 2.5: Update UI error handling for Google Sheets errors
- [x] Ensure Python CLI errors (403, 404, network) are displayed in the log view
- [x] Add user-friendly error messages in the log output for common Google Sheets issues
- **Validation**: Network and permission errors are clearly displayed to the user (errors pass through from Python CLI)

## Phase 3: Testing and Documentation

### Task 3.1: Add comprehensive unit tests
- [x] Test URL parsing and spreadsheet ID extraction
- [x] Test HTTP error handling (mock 404, 403, timeout responses)
- [x] Test input type detection with various inputs (file paths, URLs, invalid strings)
- [x] Test that CSV and Google Sheets inputs produce identical output for equivalent data
- **Validation**: All unit tests pass (19 tests); code coverage includes new logic

### Task 3.2: Add integration test with public Google Sheet
- [x] Create or identify a stable public Google Sheet for testing
- [x] Add integration test that fetches from this sheet and validates generated Swift code
- [x] Alternatively, mock HTTP responses for reproducible tests
- **Validation**: Integration test passes consistently (mocked HTTP responses in test suite)

### Task 3.3: Test backward compatibility
- [x] Run all existing CSV-based tests to ensure no regressions
- [x] Test CLI with CSV file input (existing behavior)
- [x] Test macOS UI with CSV file input (existing behavior)
- **Validation**: All existing tests pass; no breaking changes (backward compatible API maintained)

### Task 3.4: Update project documentation
- [x] Update Python README with Google Sheets examples
- [x] Add screenshots or instructions for macOS UI Google Sheets mode
- [x] Document limitations (public sheets only for MVP, network required, no caching)
- [x] Add troubleshooting guide for common issues
- **Validation**: Documentation is complete and accurate

## Phase 4: Future Enhancements (Out of Scope for MVP)

These tasks are identified for future work and are **not** part of the initial implementation:

- [ ] Add OAuth support for private Google Sheets
- [ ] Add local caching of fetched Google Sheets data
- [ ] Support Google Sheets API (beyond CSV export) for better integration
- [ ] Add UI indicator showing when data is being fetched from Google Sheets
- [ ] Support multiple sheet tabs (fetch and merge data from multiple tabs)
- [ ] Add "Refresh" button to re-fetch latest Google Sheets data without re-running generator

## Dependencies and Sequencing

- **Task 1.1-1.4 must be completed before Task 1.6** (README update requires working implementation)
- **Task 1.1-1.4 must be completed before Phase 2** (macOS UI depends on Python CLI support)
- **Task 2.1-2.4 can be done in parallel** after Phase 1 is complete
- **Phase 3 should be done continuously** alongside Phase 1 and 2 (write tests as you implement)

## Success Metrics

- All existing CSV-based workflows continue to work unchanged
- Users can generate Swift code from a Google Sheets URL via CLI
- Users can generate Swift code from a Google Sheets URL via macOS app
- Error messages for Google Sheets issues are clear and actionable
- All tests pass (unit, integration, backward compatibility)
- Documentation is complete and accurate
