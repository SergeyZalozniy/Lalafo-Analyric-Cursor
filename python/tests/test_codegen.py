from __future__ import annotations

import tempfile
from pathlib import Path

import pytest

from analytics_codegen.codegen import (
    EventRow,
    _camel_case,
    _deduplicate,
    _generate_function,
    _parse_csv,
    _pascal_case,
    generate_swift_from_csv,
)


class TestCaseConverters:
    def test_camel_case_basic(self):
        assert _camel_case("hello_world") == "helloWorld"
        assert _camel_case("foo_bar_baz") == "fooBarBaz"
        assert _camel_case("single") == "single"

    def test_camel_case_edge_cases(self):
        assert _camel_case("") == ""
        assert _camel_case("___") == ""
        assert _camel_case("_leading") == "leading"
        assert _camel_case("trailing_") == "trailing"

    def test_pascal_case_basic(self):
        assert _pascal_case("hello_world") == "HelloWorld"
        assert _pascal_case("foo_bar_baz") == "FooBarBaz"
        assert _pascal_case("single") == "Single"

    def test_pascal_case_edge_cases(self):
        assert _pascal_case("") == ""
        assert _pascal_case("___") == ""


class TestCSVParsing:
    def test_parse_valid_csv(self):
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".csv", delete=False, encoding="utf-8"
        ) as f:
            f.write("my_ad,boost_photo,post,onboarding,view,,\n")
            f.write("my_ad,boost_photo,post,button,tap,event_details,advertisement\n")
            path = Path(f.name)

        try:
            rows = _parse_csv(path)
            assert len(rows) == 2
            assert rows[0].screen == "my_ad"
            assert rows[0].action == "view"
            assert rows[0].event_details == ""
            assert rows[0].advertisement == ""
            assert rows[1].event_details == "event_details"
            assert rows[1].advertisement == "advertisement"
        finally:
            path.unlink()

    def test_parse_csv_skips_empty_lines(self):
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".csv", delete=False, encoding="utf-8"
        ) as f:
            f.write("my_ad,boost_photo,post,onboarding,view,,\n")
            f.write("\n")
            f.write(",,,,\n")
            f.write("my_ad,boost_photo,post,button,tap,,\n")
            path = Path(f.name)

        try:
            rows = _parse_csv(path)
            assert len(rows) == 2
        finally:
            path.unlink()

    def test_parse_csv_skips_incomplete_rows(self):
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".csv", delete=False, encoding="utf-8"
        ) as f:
            f.write("my_ad,boost_photo,post,onboarding,view,,\n")
            f.write("incomplete,row\n")  # Only 2 columns
            f.write("my_ad,boost_photo,post,button,tap,,\n")
            path = Path(f.name)

        try:
            rows = _parse_csv(path)
            assert len(rows) == 2
        finally:
            path.unlink()

    def test_parse_csv_file_not_found(self):
        with pytest.raises(FileNotFoundError):
            _parse_csv(Path("/nonexistent/file.csv"))


class TestDeduplication:
    def test_deduplicate_identical_rows(self):
        rows = [
            EventRow("s1", "sec1", "c1", "e1", "a1", "details", "ad"),
            EventRow("s1", "sec1", "c1", "e1", "a1", "details", "ad"),
        ]
        result = _deduplicate(rows)
        assert len(result) == 1

    def test_deduplicate_conflicting_rows(self, capsys):
        rows = [
            EventRow("s1", "sec1", "c1", "e1", "a1", "details1", "ad"),
            EventRow("s1", "sec1", "c1", "e1", "a1", "details2", "ad"),
        ]
        result = _deduplicate(rows)
        assert len(result) == 1
        assert result[0].event_details == "details1"

        captured = capsys.readouterr()
        assert "⚠️ Conflicting rows" in captured.err

    def test_deduplicate_different_advertisements(self):
        rows = [
            EventRow("s1", "sec1", "c1", "e1", "a1", "details", "ad1"),
            EventRow("s1", "sec1", "c1", "e1", "a1", "details", "ad2"),
        ]
        result = _deduplicate(rows)
        assert len(result) == 2


class TestFunctionGeneration:
    def test_generate_simple_function(self):
        row = EventRow("my_ad", "boost_photo", "post", "onboarding", "view", "", "")
        result = _generate_function(row)

        assert "func trackMyAdBoostPhotoPostOnboardingView()" in result
        assert "screen: Event.Screen.myAd" in result
        assert "section: Event.Section.boostPhoto" in result
        assert "component: Event.Component.post" in result
        assert "element: Event.Element.onboarding" in result
        assert "action: Event.Action.view" in result
        assert "EventFactory.event(with: eventDetails)" in result
        assert "trackEvent(event: event)" in result

    def test_generate_function_with_advertisement(self):
        row = EventRow(
            "my_ad", "boost_photo", "post", "button", "tap", "", "advertisement"
        )
        result = _generate_function(row)

        assert "advertisement: EventAdvertisementProtocol" in result
        assert "EventFactory.event(for: advertisement, with: eventDetails)" in result

    def test_generate_function_with_event_details(self):
        row = EventRow(
            "my_ad", "boost_photo", "post", "button", "tap", "event_details", ""
        )
        result = _generate_function(row)

        assert "parameters: [EventDetailsParameter]" in result
        assert "details: .defined(parameters)" in result

    def test_generate_function_with_parameterized_field(self):
        row = EventRow("my_ad", "boost_photo", "|", "button", "tap", "", "")
        result = _generate_function(row)

        assert "component: Event.Component" in result
        assert "func trackMyAdBoostPhotoComponentButtonTap" in result


class TestEndToEnd:
    def test_generate_swift_from_csv(self):
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".csv", delete=False, encoding="utf-8"
        ) as csv_f:
            csv_f.write("my_ad,boost_photo,post,onboarding,view,,\n")
            csv_f.write("my_ad,boost_photo,post,button,tap,event_details,ad\n")
            csv_path = Path(csv_f.name)

        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".swift", delete=False
        ) as swift_f:
            swift_path = Path(swift_f.name)

        try:
            count = generate_swift_from_csv(csv_path, swift_path)
            assert count == 2

            content = swift_path.read_text(encoding="utf-8")
            assert "// Auto-generated tracking functions" in content
            assert "trackMyAdBoostPhotoPostOnboardingView" in content
            assert "trackMyAdBoostPhotoPostButtonTap" in content
            assert "advertisement: EventAdvertisementProtocol" in content
            assert "parameters: [EventDetailsParameter]" in content
        finally:
            csv_path.unlink()
            swift_path.unlink()

    def test_idempotent_generation(self):
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
            # Generate twice
            generate_swift_from_csv(csv_path, swift_path)
            first_content = swift_path.read_text(encoding="utf-8")

            generate_swift_from_csv(csv_path, swift_path)
            second_content = swift_path.read_text(encoding="utf-8")

            assert first_content == second_content
        finally:
            csv_path.unlink()
            swift_path.unlink()
