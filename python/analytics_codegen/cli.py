from __future__ import annotations

import argparse
import sys
from pathlib import Path

from .codegen import generate_swift_from_csv


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
        help="Path to analytics CSV file (default: analytics.csv)",
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

    input_path = Path(args.input)
    output_path = Path(args.output)

    try:
        count = generate_swift_from_csv(input_path, output_path)
    except FileNotFoundError as e:
        print(f"❌ {e}", file=sys.stderr)
        return 1
    except ValueError as e:
        print(f"❌ {e}", file=sys.stderr)
        return 1

    print(f"✅ Generated {count} functions → {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


