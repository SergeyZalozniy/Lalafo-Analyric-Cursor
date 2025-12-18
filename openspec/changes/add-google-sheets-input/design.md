# Design: Google Sheets Input Support

## Architecture Overview

This design adds Google Sheets input support to the analytics code generator while preserving the existing CSV functionality. The approach is to abstract the input source behind a common interface, allowing the code generator to work with tabular data regardless of its origin.

## Design Principles

1. **Minimal changes to core logic**: The Swift code generation logic (`_generate_function`, `_deduplicate`, etc.) remains unchanged
2. **Input abstraction**: Create a unified input abstraction that handles both CSV files and Google Sheets URLs
3. **Fail-fast validation**: Detect and report input source issues (invalid URL, network failure, permission errors) before attempting generation
4. **Backward compatibility**: All existing CSV-based workflows continue to work without modification

## Component Design

### 1. Input Source Detection

The CLI and UI need to detect whether the input is a file path or a Google Sheets URL.

**Detection logic:**
```python
def detect_input_type(input_str: str) -> InputType:
    if input_str.startswith('http://') or input_str.startswith('https://'):
        if 'docs.google.com/spreadsheets' in input_str:
            return InputType.GOOGLE_SHEETS
        else:
            raise ValueError(f"Unsupported URL: {input_str}")
    else:
        return InputType.CSV_FILE
```

### 2. Google Sheets Data Fetcher

Fetch sheet data using Google's CSV export URL feature, which doesn't require OAuth for publicly shared sheets.

**URL format:**
```
https://docs.google.com/spreadsheets/d/{SPREADSHEET_ID}/export?format=csv&gid={SHEET_GID}
```

- `SPREADSHEET_ID`: Extracted from the input URL
- `SHEET_GID`: Optional sheet identifier; defaults to first sheet (gid=0) if not specified

**Implementation approach:**
- Use Python's `urllib.request` (built-in) or `requests` library to fetch the CSV export
- Parse the fetched CSV data using the existing `_parse_csv` logic
- Handle HTTP errors (404, 403, etc.) with clear error messages

**Error handling:**
| Error Code | Meaning | User Message |
|------------|---------|--------------|
| 404 | Sheet not found | "Google Sheet not found. Check the URL and ensure the sheet exists." |
| 403 | Permission denied | "Permission denied. Ensure the Google Sheet is publicly accessible or shared with you." |
| Network error | No internet / timeout | "Network error: Unable to connect to Google Sheets. Check your internet connection." |
| Invalid URL | Malformed URL | "Invalid Google Sheets URL. Expected format: https://docs.google.com/spreadsheets/d/SHEET_ID" |

### 3. Unified Input Abstraction

Create an abstraction that provides CSV rows regardless of the source:

```python
from abc import ABC, abstractmethod
from typing import List

class InputSource(ABC):
    @abstractmethod
    def get_csv_rows(self) -> List[List[str]]:
        """Return CSV rows as list of lists."""
        pass

class FileInputSource(InputSource):
    def __init__(self, file_path: Path):
        self.file_path = file_path

    def get_csv_rows(self) -> List[List[str]]:
        # Existing CSV file reading logic
        pass

class GoogleSheetsInputSource(InputSource):
    def __init__(self, url: str):
        self.url = url
        self.sheet_id = self._extract_sheet_id(url)
        self.gid = self._extract_gid(url)

    def get_csv_rows(self) -> List[List[str]]:
        # Fetch CSV export from Google Sheets
        export_url = self._build_export_url()
        csv_data = self._fetch_csv(export_url)
        return csv_data
```

**Refactored generation flow:**
```python
def generate_swift_from_input(
    input_source: InputSource,
    output_path: Path,
) -> int:
    csv_rows = input_source.get_csv_rows()
    rows = _parse_csv_rows(csv_rows)  # Refactored from _parse_csv
    rows = _deduplicate(rows)
    # ... rest of generation logic
```

### 4. CLI Changes

Update the CLI to accept both file paths and URLs:

```python
parser.add_argument(
    "--input",
    "-i",
    type=str,
    default="analytics.csv",
    help="Path to CSV file or Google Sheets URL (default: analytics.csv)",
)
```

The CLI will detect the input type and create the appropriate `InputSource`:

```python
def main(argv: list[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)

    input_type = detect_input_type(args.input)

    if input_type == InputType.GOOGLE_SHEETS:
        input_source = GoogleSheetsInputSource(args.input)
    else:
        input_source = FileInputSource(Path(args.input))

    try:
        count = generate_swift_from_input(input_source, Path(args.output))
    except (FileNotFoundError, ValueError, URLError) as e:
        print(f"❌ {e}", file=sys.stderr)
        return 1

    print(f"✅ Generated {count} functions → {args.output}")
    return 0
```

### 5. macOS UI Changes

The Swift macOS app needs to support both input modes.

**UI approach:**
- Add a **Picker/SegmentedControl** to toggle between "File" and "Google Sheets" modes
- In "File" mode: Show CSV file browser (current behavior)
- In "Google Sheets" mode: Show a text field for entering the Google Sheets URL

**Updated ContentView state:**
```swift
enum InputMode: String, CaseIterable {
    case file = "File"
    case googleSheets = "Google Sheets"
}

@State private var inputMode: InputMode = .file
@State private var googleSheetsURL: String = ""
```

**Python runner update:**
The `runPythonGenerator` function will pass either `--input <file_path>` or `--input <url>` based on the selected mode.

## Trade-offs and Alternatives

### Alternative 1: Always require manual CSV export
**Rejected** because it adds friction and manual steps to the workflow.

### Alternative 2: Full Google Sheets API integration with OAuth
**Rejected for MVP** because:
- Adds significant complexity (OAuth flow, credential management)
- Not necessary if we can use public/view-only sheet export URLs
- Can be added later if authenticated access becomes a requirement

### Alternative 3: Support Google Sheets but cache locally as CSV
**Considered but deferred** because:
- Adds complexity around cache invalidation
- Users can manually save CSV if offline access is needed
- Can be added as an enhancement later

### Chosen Approach: Direct CSV export URL
**Selected** because:
- Simple implementation using Google's built-in CSV export
- No authentication needed for publicly shared sheets
- Minimal dependencies (standard HTTP library)
- Fail-fast with clear error messages
- Easy to extend later with OAuth if needed

## Testing Strategy

1. **Unit tests**: Test URL parsing, sheet ID extraction, and input source abstraction
2. **Integration tests**: Test fetching from a known public Google Sheet
3. **Error handling tests**: Mock HTTP errors (403, 404, timeout) and validate error messages
4. **Backward compatibility tests**: Ensure all existing CSV tests still pass
5. **End-to-end test**: Full workflow from Google Sheets URL to generated Swift code

## Security Considerations

1. **URL validation**: Only allow `https://docs.google.com/spreadsheets/*` URLs to prevent SSRF attacks
2. **No credentials in code**: Never hard-code API keys or OAuth credentials
3. **Public sheets only (MVP)**: Initial version only supports publicly accessible sheets
4. **HTTPS only**: Reject `http://` URLs for Google Sheets

## Performance Considerations

- **Network latency**: Fetching from Google Sheets adds network latency vs. local CSV
- **No caching**: Each run fetches fresh data (ensures latest version but requires network)
- **Rate limits**: Google may rate-limit export URL requests; document this limitation

## Rollout Plan

1. **Phase 1 (MVP)**: Python CLI support for Google Sheets URLs using export URLs
2. **Phase 2**: macOS UI support with input mode toggle
3. **Phase 3** (future): Add OAuth support for private sheets
4. **Phase 4** (future): Add local caching for offline access
