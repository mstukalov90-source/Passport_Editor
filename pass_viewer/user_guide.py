"""Render USER_GUIDE.md as HTML for the home page modal."""

from __future__ import annotations

import re
from functools import lru_cache
from pathlib import Path

import markdown
from django.conf import settings
from django.templatetags.static import static

_MD_PATH = Path(settings.BASE_DIR) / "USER_GUIDE.md"
_IMAGE_PREFIX = "docs/user-guide/images/"
_STATIC_IMAGE_PREFIX = "pass_viewer/img/user-guide/"


def _slugify_heading(text: str) -> str:
    """Match USER_GUIDE anchor style, e.g. ``8. Объединение паспортов`` → ``8-объединение-паспортов``."""
    plain = re.sub(r"\*\*([^*]+)\*\*", r"\1", text)
    plain = plain.strip().lower()
    plain = plain.replace(".", " ")
    plain = re.sub(r"\s+", "-", plain)
    plain = re.sub(r"[^\w\-]", "", plain, flags=re.UNICODE)
    return re.sub(r"-+", "-", plain).strip("-")


def _rewrite_image_paths(md_text: str) -> str:
    def repl(match: re.Match[str]) -> str:
        alt = match.group(1)
        filename = match.group(2)
        url = static(f"{_STATIC_IMAGE_PREFIX}{filename}")
        return f"![{alt}]({url})"

    return re.sub(
        r"!\[([^\]]*)\]\(" + re.escape(_IMAGE_PREFIX) + r"([^)]+)\)",
        repl,
        md_text,
    )


def _add_heading_ids(html: str) -> str:
    def repl(match: re.Match[str]) -> str:
        level = match.group(1)
        inner = match.group(2)
        slug = _slugify_heading(re.sub(r"<[^>]+>", "", inner))
        if not slug:
            return match.group(0)
        return f'<h{level} id="{slug}">{inner}</h{level}>'

    return re.sub(r"<h([23])>(.*?)</h\1>", repl, html, flags=re.DOTALL)


def _enhance_images(html: str) -> str:
    def repl(match: re.Match[str]) -> str:
        tag = match.group(0)
        if "loading=" in tag:
            return tag
        if "class=" in tag:
            tag = re.sub(r'class="([^"]*)"', r'class="\1 user-guide-img"', tag)
        else:
            tag = tag.replace("<img ", '<img class="user-guide-img" ', 1)
        return tag.replace("<img ", '<img loading="lazy" ', 1)

    return re.sub(r"<img\s[^>]*>", repl, html)


@lru_cache(maxsize=1)
def load_user_guide_html() -> str:
    if not _MD_PATH.is_file():
        return '<p class="note">Руководство пользователя недоступно.</p>'
    md_text = _MD_PATH.read_text(encoding="utf-8")
    md_text = _rewrite_image_paths(md_text)
    html = markdown.markdown(
        md_text,
        extensions=["tables", "nl2br", "sane_lists"],
    )
    html = _add_heading_ids(html)
    html = _enhance_images(html)
    return html
