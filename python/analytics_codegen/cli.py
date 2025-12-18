from __future__ import annotations

import argparse
import sys
from pathlib import Path

from .codegen import generate_swift_from_input
from .input_source import (
    FileInputSource,
    GoogleSheetsInputSource,
    InputType,
    detect_input_type,
)


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Generate Swift analytics tracking functions from a CSV file "
            "using the 7-column analytics schema."
        )
    )
    parser.add_argument(
        "--input",
        "-i",
        type=str,
        default="analytics.csv",
        help=(
            "Path to CSV file or Google Sheets URL "
            "(default: analytics.csv)"
        ),
    )
    parser.add_argument(
        "--output",
        "-o",
        type=str,
        default="Swift/GeneratedTrackingFunctions.swift",
        help=(
            "Path to output Swift file "
            "(default: Swift/GeneratedTrackingFunctions.swift)"
        ),
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)

    output_path = Path(args.output)

    try:
        # Detect input type
        input_type = detect_input_type(args.input)

        # Create appropriate input source
        if input_type == InputType.GOOGLE_SHEETS:
            input_source = GoogleSheetsInputSource(args.input)
        else:
            input_source = FileInputSource(Path(args.input))

        # Generate Swift code
        count = generate_swift_from_input(input_source, output_path)

    except FileNotFoundError as e:
        print(f"❌ {e}", file=sys.stderr)
        return 1
    except ValueError as e:
        print(f"❌ {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"❌ Unexpected error: {e}", file=sys.stderr)
        return 1

    print(f"✅ Generated {count} functions → {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


