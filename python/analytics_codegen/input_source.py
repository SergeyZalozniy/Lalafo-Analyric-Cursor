from __future__ import annotations

import csv
import re
import sys
from abc import ABC, abstractmethod
from enum import Enum
from pathlib import Path
from typing import List
from urllib import error, request


class InputType(Enum):
    """Type of input source for analytics event definitions."""

    CSV_FILE = "csv_file"
    GOOGLE_SHEETS = "google_sheets"


def detect_input_type(input_str: str) -> InputType:
    """
    Detect whether input is a file path or Google Sheets URL.

    Args:
        input_str: Input string (file path or URL)

    Returns:
        InputType enum value

    Raises:
        ValueError: If URL is not a valid Google Sheets URL
    """
    input_str = input_str.strip()

    # Check if it's a URL
    if input_str.startswith("http://") or input_str.startswith("https://"):
        # Only allow HTTPS for Google Sheets
        if input_str.startswith("http://"):
            raise ValueError(
                "Google Sheets URLs must use HTTPS. "
                "Please use https:// instead of http://"
            )

        # Validate it's a Google Sheets URL
        if "docs.google.com/spreadsheets" in input_str:
            return InputType.GOOGLE_SHEETS
        else:
            raise ValueError(
                f"Unsupported URL: {input_str}\n"
                "Only Google Sheets URLs are supported. "
                "Expected format: https://docs.google.com/spreadsheets/d/SHEET_ID"
            )
    else:
        # Treat as file path
        return InputType.CSV_FILE


class InputSource(ABC):
    """Abstract base class for input sources providing CSV row data."""

    @abstractmethod
    def get_csv_rows(self) -> List[List[str]]:
        """
        Return CSV rows as list of lists.

        Returns:
            List of CSV rows, where each row is a list of string values

        Raises:
            FileNotFoundError: If input source is not accessible
            ValueError: If input data is invalid
        """
        pass


class FileInputSource(InputSource):
    """Input source that reads from a local CSV file."""

    def __init__(self, file_path: Path):
        """
        Initialize file input source.

        Args:
            file_path: Path to CSV file
        """
        self.file_path = file_path

    def get_csv_rows(self) -> List[List[str]]:
        """
        Read CSV rows from file.

        Returns:
            List of CSV rows

        Raises:
            FileNotFoundError: If file doesn't exist
        """
        if not self.file_path.is_file():
            raise FileNotFoundError(f"Input file not found: {self.file_path}")

        rows: List[List[str]] = []
        with self.file_path.open("r", encoding="utf-8", newline="") as f:
            reader = csv.reader(f)
            for raw_row in reader:
                rows.append(raw_row)

        return rows


class GoogleSheetsInputSource(InputSource):
    """Input source that fetches data from a Google Sheets URL."""

    def __init__(self, url: str):
        """
        Initialize Google Sheets input source.

        Args:
            url: Google Sheets URL

        Raises:
            ValueError: If URL is invalid
        """
        self.url = url
        self.sheet_id = self._extract_sheet_id(url)
        self.gid = self._extract_gid(url)

    def _extract_sheet_id(self, url: str) -> str:
        """
        Extract spreadsheet ID from Google Sheets URL.

        Args:
            url: Google Sheets URL

        Returns:
            Spreadsheet ID

        Raises:
            ValueError: If ID cannot be extracted
        """
        # Pattern: https://docs.google.com/spreadsheets/d/{SHEET_ID}/...
        match = re.search(r"/spreadsheets/d/([a-zA-Z0-9-_]+)", url)
        if not match:
            raise ValueError(
                f"Invalid Google Sheets URL: {url}\n"
                "Expected format: https://docs.google.com/spreadsheets/d/SHEET_ID"
            )
        return match.group(1)

    def _extract_gid(self, url: str) -> str:
        """
        Extract sheet GID (tab identifier) from URL if present.

        Args:
            url: Google Sheets URL

        Returns:
            Sheet GID, or "0" (first sheet) if not specified
        """
        # Pattern: ...#gid=123 or ...&gid=123
        match = re.search(r"[#&]gid=([0-9]+)", url)
        if match:
            return match.group(1)
        return "0"  # Default to first sheet

    def _build_export_url(self) -> str:
        """
        Build CSV export URL for Google Sheets.

        Returns:
            CSV export URL
        """
        base_url = (
            f"https://docs.google.com/spreadsheets/d/{self.sheet_id}/export"
        )
        return f"{base_url}?format=csv&gid={self.gid}"

    def get_csv_rows(self) -> List[List[str]]:
        """
        Fetch CSV data from Google Sheets.

        Returns:
            List of CSV rows

        Raises:
            FileNotFoundError: If sheet is not found (404)
            ValueError: If permission is denied (403) or network error occurs
        """
        export_url = self._build_export_url()

        try:
            with request.urlopen(export_url, timeout=30) as response:
                # Read and decode response
                data = response.read().decode("utf-8")

                # Parse CSV data
                rows: List[List[str]] = []
                reader = csv.reader(data.splitlines())
                for raw_row in reader:
                    rows.append(raw_row)

                return rows

        except error.HTTPError as e:
            if e.code == 404:
                raise FileNotFoundError(
                    f"Google Sheet not found: {self.url}\n"
                    "Check the URL and ensure the sheet exists."
                ) from e
            elif e.code == 403:
                raise ValueError(
                    f"Permission denied: {self.url}\n"
                    "Ensure the Google Sheet is publicly accessible or "
                    "shared with 'Anyone with the link can view'."
                ) from e
            else:
                raise ValueError(
                    f"HTTP error {e.code} when fetching Google Sheet: {self.url}\n"
                    f"Details: {e.reason}"
                ) from e

        except error.URLError as e:
            raise ValueError(
                f"Network error: Unable to connect to Google Sheets.\n"
                f"Check your internet connection and try again.\n"
                f"Details: {e.reason}"
            ) from e

        except Exception as e:
            raise ValueError(
                f"Unexpected error fetching Google Sheet: {self.url}\n"
                f"Details: {str(e)}"
            ) from e
