"""Ensure committed page JS matches _extracted snapshots."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BUILD_SCRIPT = ROOT / "pass_viewer/static/build_page_js.py"


def test_page_js_in_sync_with_extracted() -> None:
    result = subprocess.run(
        [sys.executable, str(BUILD_SCRIPT), "--check"],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, result.stderr or result.stdout
