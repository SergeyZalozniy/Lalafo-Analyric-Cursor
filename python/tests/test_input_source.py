"""Tests for input source detection and abstraction."""

from __future__ import annotations

import io
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch
from urllib import error

from analytics_codegen.input_source import (
    FileInputSource,
    GoogleSheetsInputSource,
    InputType,
    detect_input_type,
)


class TestDetectInputType(unittest.TestCase):
    """Test input type detection."""

    def test_detect_csv_file(self):
        """Test detection of CSV file path."""
        result = detect_input_type("/path/to/analytics.csv")
        self.assertEqual(result, InputType.CSV_FILE)

    def test_detect_relative_path(self):
        """Test detection of relative file path."""
        result = detect_input_type("analytics.csv")
        self.assertEqual(result, InputType.CSV_FILE)

    def test_detect_google_sheets_url(self):
        """Test detection of Google Sheets URL."""
        url = "https://docs.google.com/spreadsheets/d/ABC123/edit"
        result = detect_input_type(url)
        self.assertEqual(result, InputType.GOOGLE_SHEETS)

    def test_detect_google_sheets_with_gid(self):
        """Test detection of Google Sheets URL with gid."""
        url = "https://docs.google.com/spreadsheets/d/ABC123/edit#gid=456"
        result = detect_input_type(url)
        self.assertEqual(result, InputType.GOOGLE_SHEETS)

    def test_reject_http_url(self):
        """Test rejection of HTTP (not HTTPS) URL."""
        url = "http://docs.google.com/spreadsheets/d/ABC123/edit"
        with self.assertRaises(ValueError) as cm:
            detect_input_type(url)
        self.assertIn("HTTPS", str(cm.exception))

    def test_reject_non_google_sheets_url(self):
        """Test rejection of non-Google Sheets URL."""
        url = "https://example.com/spreadsheet"
        with self.assertRaises(ValueError) as cm:
            detect_input_type(url)
        self.assertIn("Unsupported URL", str(cm.exception))


class TestGoogleSheetsInputSource(unittest.TestCase):
    """Test Google Sheets input source."""

    def test_extract_sheet_id(self):
        """Test extraction of spreadsheet ID from URL."""
        url = "https://docs.google.com/spreadsheets/d/ABC123XYZ/edit"
        source = GoogleSheetsInputSource(url)
        self.assertEqual(source.sheet_id, "ABC123XYZ")

    def test_extract_sheet_id_with_params(self):
        """Test extraction of spreadsheet ID from URL with parameters."""
        url = "https://docs.google.com/spreadsheets/d/ABC-123_XYZ/edit#gid=0"
        source = GoogleSheetsInputSource(url)
        self.assertEqual(source.sheet_id, "ABC-123_XYZ")

    def test_extract_gid_from_hash(self):
        """Test extraction of gid from URL hash."""
        url = "https://docs.google.com/spreadsheets/d/ABC123/edit#gid=789"
        source = GoogleSheetsInputSource(url)
        self.assertEqual(source.gid, "789")

    def test_extract_gid_from_query(self):
        """Test extraction of gid from query parameters."""
        url = "https://docs.google.com/spreadsheets/d/ABC123/export?format=csv&gid=456"
        source = GoogleSheetsInputSource(url)
        self.assertEqual(source.gid, "456")

    def test_default_gid(self):
        """Test default gid when not specified."""
        url = "https://docs.google.com/spreadsheets/d/ABC123/edit"
        source = GoogleSheetsInputSource(url)
        self.assertEqual(source.gid, "0")

    def test_build_export_url(self):
        """Test building CSV export URL."""
        url = "https://docs.google.com/spreadsheets/d/ABC123/edit"
        source = GoogleSheetsInputSource(url)
        export_url = source._build_export_url()
        self.assertEqual(
            export_url,
            "https://docs.google.com/spreadsheets/d/ABC123/export?format=csv&gid=0",
        )

    def test_build_export_url_with_gid(self):
        """Test building CSV export URL with specific gid."""
        url = "https://docs.google.com/spreadsheets/d/ABC123/edit#gid=456"
        source = GoogleSheetsInputSource(url)
        export_url = source._build_export_url()
        self.assertEqual(
            export_url,
            "https://docs.google.com/spreadsheets/d/ABC123/export?format=csv&gid=456",
        )

    def test_invalid_url_missing_id(self):
        """Test error on URL missing spreadsheet ID."""
        url = "https://docs.google.com/spreadsheets/"
        with self.assertRaises(ValueError) as cm:
            GoogleSheetsInputSource(url)
        self.assertIn("Invalid Google Sheets URL", str(cm.exception))

    @patch("analytics_codegen.input_source.request.urlopen")
    def test_get_csv_rows_success(self, mock_urlopen):
        """Test successful CSV data fetching."""
        # Mock HTTP response
        mock_response = MagicMock()
        mock_response.read.return_value = b"screen,section,component,element,action\nmy_ad,boost,post,button,tap"
        mock_response.__enter__.return_value = mock_response
        mock_urlopen.return_value = mock_response

        url = "https://docs.google.com/spreadsheets/d/ABC123/edit"
        source = GoogleSheetsInputSource(url)
        rows = source.get_csv_rows()

        self.assertEqual(len(rows), 2)
        self.assertEqual(rows[0], ["screen", "section", "component", "element", "action"])
        self.assertEqual(rows[1], ["my_ad", "boost", "post", "button", "tap"])

    @patch("analytics_codegen.input_source.request.urlopen")
    def test_get_csv_rows_404(self, mock_urlopen):
        """Test handling of 404 error."""
        mock_urlopen.side_effect = error.HTTPError(
            "url", 404, "Not Found", {}, io.BytesIO()
        )

        url = "https://docs.google.com/spreadsheets/d/ABC123/edit"
        source = GoogleSheetsInputSource(url)

        with self.assertRaises(FileNotFoundError) as cm:
            source.get_csv_rows()
        self.assertIn("Google Sheet not found", str(cm.exception))

    @patch("analytics_codegen.input_source.request.urlopen")
    def test_get_csv_rows_403(self, mock_urlopen):
        """Test handling of 403 error."""
        mock_urlopen.side_effect = error.HTTPError(
            "url", 403, "Forbidden", {}, io.BytesIO()
        )

        url = "https://docs.google.com/spreadsheets/d/ABC123/edit"
        source = GoogleSheetsInputSource(url)

        with self.assertRaises(ValueError) as cm:
            source.get_csv_rows()
        self.assertIn("Permission denied", str(cm.exception))

    @patch("analytics_codegen.input_source.request.urlopen")
    def test_get_csv_rows_network_error(self, mock_urlopen):
        """Test handling of network error."""
        mock_urlopen.side_effect = error.URLError("Network unreachable")

        url = "https://docs.google.com/spreadsheets/d/ABC123/edit"
        source = GoogleSheetsInputSource(url)

        with self.assertRaises(ValueError) as cm:
            source.get_csv_rows()
        self.assertIn("Network error", str(cm.exception))


class TestFileInputSource(unittest.TestCase):
    """Test file input source."""

    def test_get_csv_rows_nonexistent_file(self):
        """Test error on nonexistent file."""
        source = FileInputSource(Path("/nonexistent/file.csv"))
        with self.assertRaises(FileNotFoundError) as cm:
            source.get_csv_rows()
        self.assertIn("Input file not found", str(cm.exception))


if __name__ == "__main__":
    unittest.main()
