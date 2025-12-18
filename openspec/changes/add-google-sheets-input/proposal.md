# Proposal: Add Google Sheets Input Support

## Overview

Add Google Sheets as an input source alongside CSV files for the analytics event code generator. This allows teams to maintain their analytics event definitions in a collaborative Google Sheets document and generate Swift code directly from it, without needing to manually export to CSV.

## Motivation

Currently, the analytics code generator only accepts CSV files as input. Many teams maintain their analytics event definitions in Google Sheets for easier collaboration and real-time updates. Requiring a manual CSV export step adds friction and creates opportunities for errors when the exported CSV becomes stale.

By adding native Google Sheets support, we enable:
- **Direct integration**: Generate code from a live Google Sheets URL
- **Reduced friction**: No manual export step needed
- **Always up-to-date**: The generator always works with the latest event definitions
- **Backward compatibility**: CSV input remains fully supported

## Success Criteria

1. Users can provide a Google Sheets URL (with appropriate permissions) as input
2. The generator fetches the sheet data and processes it identically to CSV
3. CSV input continues to work exactly as before
4. The macOS UI supports both CSV file selection and Google Sheets URL input
5. Clear error messages when Google Sheets access fails (permissions, network, invalid URL)
6. Tests validate both CSV and Google Sheets input paths

## User Impact

### Before
```bash
# User must manually export from Google Sheets to CSV
python -m python.analytics_codegen.cli --input /path/to/exported.csv --output Swift/Output.swift
```

### After
```bash
# Option 1: Continue using CSV (unchanged)
python -m python.analytics_codegen.cli --input /path/to/analytics.csv --output Swift/Output.swift

# Option 2: Use Google Sheets URL directly
python -m python.analytics_codegen.cli --input "https://docs.google.com/spreadsheets/d/SHEET_ID" --output Swift/Output.swift
```

The macOS UI will also support entering a Google Sheets URL in addition to browsing for a CSV file.

## Non-Goals

- **Not** building a full Google Sheets API wrapper (only reading tabular data)
- **Not** supporting Google Sheets authentication flows (assumes publicly readable or user-authenticated sheets)
- **Not** supporting real-time sync or watching for changes (one-time fetch only)
- **Not** modifying the 7-column event schema or CSV parsing logic

## Dependencies

- Google Sheets API or public export URL mechanism for fetching sheet data
- Python HTTP client library (e.g., `requests` or built-in `urllib`)
- Optional: Google API client libraries if authenticated access is required

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Network failures when fetching sheets | Generation fails | Clear error messages; fallback to cached CSV if available |
| Google API rate limits | Throttling or failures | Document rate limits; consider caching responses |
| Authentication complexity | Setup friction | Start with public/view-only sheets; document setup steps clearly |
| Breaking changes to Google Sheets API | Integration breaks | Use stable export URLs rather than full API integration |

## Open Questions

1. **Authentication approach**: Should we support authenticated sheets, or start with public view-only access?
   - Recommendation: Start with public sheets using export URLs (`/export?format=csv`), add OAuth later if needed

2. **Sheet selection**: If a spreadsheet has multiple sheets/tabs, how do we specify which one?
   - Recommendation: Support `gid` parameter in URL, or default to first sheet

3. **Caching**: Should we cache fetched sheet data locally?
   - Recommendation: No caching for MVP; users can save CSV manually if offline access is needed

4. **UI changes**: How should the macOS app present the choice between CSV and Google Sheets?
   - Recommendation: Add a segmented control or tabs to switch between "File" and "Google Sheets URL" modes
