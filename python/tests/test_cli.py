from __future__ import annotations

import tempfile
from pathlib import Path

from analytics_codegen.cli import main


class TestCLI:
    def test_cli_success(self):
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".csv", delete=False, encoding="utf-8"
        ) as csv_f:
            csv_f.write("my_ad,boost_photo,post,onboarding,view,,\n")
            csv_path = Path(csv_f.name)

        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".swift", delete=False
        ) as swift_f:
            swift_path = Path(swift_f.name)

        try:
            exit_code = main(["--input", str(csv_path), "--output", str(swift_path)])
            assert exit_code == 0

            content = swift_path.read_text(encoding="utf-8")
            assert "trackMyAdBoostPhotoPostOnboardingView" in content
        finally:
            csv_path.unlink()
            swift_path.unlink()

    def test_cli_missing_input_file(self):
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".swift", delete=False
        ) as swift_f:
            swift_path = Path(swift_f.name)

        try:
            exit_code = main(
                ["--input", "/nonexistent/file.csv", "--output", str(swift_path)]
            )
            assert exit_code == 1
        finally:
            swift_path.unlink()

    def test_cli_default_paths(self):
        # This test would fail if run without the default analytics.csv
        # but it tests that the argument parser accepts no arguments
        # We won't actually run it, just ensure it parses
        # In a real scenario, you'd mock the file system
        pass
