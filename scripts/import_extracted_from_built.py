#!/usr/bin/env python3
"""
One-way import: built page JS -> _extracted snapshot (reverse of build_page_js.py).

Usage:
  python3 scripts/import_extracted_from_built.py --page home
  python3 scripts/import_extracted_from_built.py --all
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "pass_viewer" / "static"))

from build_page_js import (  # noqa: E402
    EXTRACTED,
    FOOTER,
    PAGE_HEADERS,
    PAGE_MAP,
    ROOT as JS_ROOT,
    apply_reverse_replacements,
)


def strip_built_wrapper(content: str, src_name: str) -> str:
    header = PAGE_HEADERS[src_name]
    if not content.startswith(header):
        raise ValueError(f"{PAGE_MAP[src_name]}: header mismatch (update PAGE_HEADERS or re-import manually)")
    body = content[len(header) :]
    if body.endswith(FOOTER):
        body = body[: -len(FOOTER)]
    else:
        raise ValueError(f"{PAGE_MAP[src_name]}: footer mismatch")
    return body.strip() + "\n"


def import_page(src_name: str) -> None:
    out_name = PAGE_MAP[src_name]
    built_path = JS_ROOT / out_name
    if not built_path.is_file():
        raise SystemExit(f"Missing built file: {built_path}")
    content = built_path.read_text(encoding="utf-8")
    body = strip_built_wrapper(content, src_name)
    body = apply_reverse_replacements(body)
    dest = EXTRACTED / f"{src_name}.js"
    dest.write_text(body, encoding="utf-8")
    print(f"imported {out_name} -> _extracted/{src_name}.js ({len(body.splitlines())} lines)")


def main() -> None:
    parser = argparse.ArgumentParser(description="Import built page JS into _extracted snapshots.")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--page", choices=sorted(PAGE_MAP.keys()))
    group.add_argument("--all", action="store_true")
    args = parser.parse_args()

    EXTRACTED.mkdir(parents=True, exist_ok=True)

    if args.all:
        for src_name in PAGE_MAP:
            import_page(src_name)
        return

    import_page(args.page)


if __name__ == "__main__":
    main()
