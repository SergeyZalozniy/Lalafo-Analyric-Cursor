## Analytics Swift Tracking Codegen (Python)

This Python tool generates **Swift analytics tracking functions** from a CSV file
using the same 7-column schema as your existing `generate_tracking.swift` script.

### Running Tests

To run the unit tests:

```bash
# Install dev dependencies
pip install -r requirements-dev.txt

# Run tests
python -m pytest tests/ -v
```

### CSV schema

The generator supports two formats:

#### Format 1: With Header Row (Recommended for Google Sheets)
The first row contains column names with colons. The generator automatically detects columns by name:

| Header Name     | Required | Description |
|-----------------|----------|-------------|
| `screen:`       | ✅       | Event screen name (`Event.Screen`) |
| `section:`      | ✅       | Event section name (`Event.Section`) |
| `component:`    | ✅       | Component name (`Event.Component`) |
| `element:`      | ✅       | UI element name (`Event.Element`) |
| `action:`       | ✅       | Event action (e.g. `tap`, `view`, `error`; `Event.Action`) |
| `event_details` | ❌       | Optional dynamic event details; if non-empty, adds `parameters: [EventDetailsParameter]` and `details: .defined(parameters)` |
| `advertisement` | ❌       | Optional; if non-empty, adds `advertisement: EventAdvertisementProtocol` and uses `EventFactory.event(for:with:)` |

**Note:** Column order doesn't matter when using headers - the generator finds columns by name.

**Multi-variant sections:** If a section contains multiple space-separated variants (e.g., `reach_category_advertise_button reach_category_after_posting`), the generator will:
1. Remove any Cyrillic text (Ukrainian/Russian comments)
2. Split by whitespace to extract individual variants
3. Generate a separate function for each variant

Example:
```
section: "reach_category_advertise_button - якщо потрапили НЕ з флоу постінга
         reach_category_after_posting - якщо потрапили з флоу постінга"
```
Will generate two functions:
- `trackPpv*ReachCategoryAdvertiseButton*ButtonView(...)`
- `trackPpv*ReachCategoryAfterPosting*ButtonView(...)`

#### Format 2: Positional (Legacy, no headers)
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

#### From CSV File

From the repository root:

```bash
python -m python.analytics_codegen.cli \
  --input /absolute/path/to/analytics.csv \
  --output Swift/GeneratedTrackingFunctions.swift
```

#### From Google Sheets

You can also generate code directly from a Google Sheets URL:

```bash
python -m python.analytics_codegen.cli \
  --input "https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID/edit" \
  --output Swift/GeneratedTrackingFunctions.swift
```

**Requirements for Google Sheets:**
- The sheet must be publicly accessible or shared with "Anyone with the link can view"
- The URL must use HTTPS (not HTTP)
- The sheet should follow the same 7-column schema as CSV files

**Specifying a particular sheet tab:**
If your spreadsheet has multiple tabs, you can specify which one to use by including the `gid` parameter in the URL:

```bash
python -m python.analytics_codegen.cli \
  --input "https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID/edit#gid=123456" \
  --output Swift/GeneratedTrackingFunctions.swift
```

If no `gid` is specified, the first sheet (gid=0) will be used by default.

#### Defaults

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

### Swift Usage Examples

Once you've generated the Swift functions in `Swift/GeneratedTrackingFunctions.swift`, you can call them from your Swift code. The generated functions integrate with your existing analytics infrastructure (`Event`, `EventsTracker`, `EventFactory`).

**Example 1: Simple event with no parameters**

```swift
// Generated from CSV row:
// my_ad,boost_photo,post,onboarding,view,,
trackMyAdBoostPhotoPostOnboardingView()
```

**Example 2: Event with advertisement and event details parameters**

```swift
// Generated from CSV row:
// my_ad,boost_photo,post,button,tap,event_details,advertisement
let ad = YourAdvertisementObject() // implements EventAdvertisementProtocol
let params: [EventDetailsParameter] = [
    EventDetailsParameter(key: "button_type", value: "primary"),
    EventDetailsParameter(key: "screen_position", value: "top")
]
trackMyAdBoostPhotoPostButtonTap(advertisement: ad, parameters: params)
```

**Example 3: Using from an extension or wrapper**

You can add the generated functions to your existing analytics layer by placing them in an extension of your tracker class:

```swift
extension EventsTracker {
    // Paste generated functions here, or import from GeneratedTrackingFunctions.swift
}

// Then call from anywhere in your app:
EventsTracker.trackMyAdBoostPhotoPostOnboardingView()
```

**Integration Notes:**
- Generated functions call `trackEvent(event:)` which should exist in your analytics infrastructure
- They use `EventFactory.event(with:)` or `EventFactory.event(for:with:)` to create events
- All enum values reference `Event.Screen`, `Event.Section`, `Event.Component`, `Event.Element`, and `Event.Action`
- If you see compilation errors, ensure these types are defined in `Event.swift` and `EventsTracker.swift`

### Troubleshooting Google Sheets

#### Error: "Permission denied"
**Problem:** The Google Sheet is not publicly accessible.

**Solution:** Make the sheet publicly viewable:
1. Open the Google Sheet
2. Click "Share" in the top right
3. Change "Restricted" to "Anyone with the link"
4. Set permission to "Viewer"
5. Click "Done"

#### Error: "Google Sheet not found"
**Problem:** The URL is incorrect or the sheet has been deleted.

**Solution:**
- Verify the URL is correct and the sheet exists
- Make sure you're using the full URL from your browser's address bar
- Check that the sheet ID in the URL is valid

#### Error: "Network error: Unable to connect to Google Sheets"
**Problem:** No internet connection or Google Sheets is unavailable.

**Solution:**
- Check your internet connection
- Try accessing the sheet in a web browser
- If Google Sheets is down, wait and try again later
- As a fallback, manually export the sheet to CSV and use that instead

#### Error: "Invalid Google Sheets URL"
**Problem:** The URL format is not recognized.

**Solution:**
- Use the full URL from your browser: `https://docs.google.com/spreadsheets/d/SHEET_ID/edit`
- Make sure the URL starts with `https://` (not `http://`)
- Ensure the URL contains `/spreadsheets/d/`

#### Making a Google Sheet Public
To share a Google Sheet so the generator can access it:

1. Open your Google Sheet
2. Click the "Share" button (top right corner)
3. Click "Change to anyone with the link"
4. Set the role to "Viewer"
5. Click "Done"
6. Copy the URL from your browser and use it with the `--input` flag


