#!/usr/bin/env python3
"""Export database-free HTML previews for the designer.

The previews are rendered from the live Django templates but use deliberately
fictional data.  The generated pages do not include application JavaScript, so
they can safely be opened with ``file://`` and never request the API or DB.
"""

from __future__ import annotations

import argparse
import html as html_lib
import os
import re
import shutil
import sys
from pathlib import Path


PROJECT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = PROJECT_DIR / "designer_preview"
STATIC_URL_RE = re.compile(r'(["\'])/static/([^"\']+)\1')
SCRIPTS_RE = re.compile(r"\s*<script\b[^>]*>.*?</script>\s*", re.IGNORECASE | re.DOTALL)
REMOTE_STYLES_RE = re.compile(
    r"\s*<link\b[^>]*\bhref=[\"']https?://[^\"']+[\"'][^>]*>\s*", re.IGNORECASE
)
LOCAL_LINK_RE = re.compile(r'\bhref="/(?!static/)[^"]*"')
LOCAL_ACTION_RE = re.compile(r'\baction="/[^"]*"')
ELEMENT_RE = re.compile(r"<(?P<tag>div|dialog)\b(?P<attrs>[^>]*)>", re.IGNORECASE)
HEADING_RE = re.compile(r"<h[1-4]\b[^>]*>(.*?)</h[1-4]>", re.IGNORECASE | re.DOTALL)


SAMPLE_OBJECTS = [
    {
        "rootid": "77:04:0001001:12345",
        "request_id": "240817-001",
        "name": "Детская площадка у дома 12",
        "source_label": "ДТ",
    },
    {
        "rootid": "77:04:0001001:12346",
        "request_id": "240817-002",
        "name": "Сквер на улице Академика Королёва",
        "source_label": "ОЗН",
    },
    {
        "rootid": "",
        "request_id": "240817-003",
        "name": "Благоустройство дворовой территории",
        "source_label": "ОДХ",
        "object_key": "(0,1)",
        "is_ods_request": False,
    },
]


def page_contexts() -> dict[str, tuple[str, dict[str, object]]]:
    from django.contrib.auth.forms import AuthenticationForm

    empty_layers = {
        "selected_geometry_json": None,
        "selected_geometry_for_editing_json": None,
        "intersects_geometry_json": None,
        "touches_geometry_json": None,
        "nearby_geometry_json": None,
        "dgi_moscow_rent_geometry_json": None,
        "dgi_moscow_no_rent_geometry_json": None,
        "dgi_private_rent_geometry_json": None,
        "dgi_private_no_rent_geometry_json": None,
        "dgi_renovation_geometry_json": None,
        "odh_geometry_json": None,
        "ozn_geometry_json": None,
        "renew_geometry_json": None,
        "oozt_geometry_json": None,
        "rzd_geometry_json": None,
        "top_geometry_json": None,
        "recaps_geometry_json": None,
        "request_objects_geometry_json": None,
    }
    home = {
        "page_config": {},
        "owned_passports_geojson": None,
        "hood_work_area_geojson": None,
        "user_role": "DEP",
        "owner_id": "00000000-0000-0000-0000-000000000001",
        "owner_name": "Демонстрационный балансодержатель",
        "display_name": "Демонстрационный пользователь",
        "can_write": True,
        "owned_objects": SAMPLE_OBJECTS,
        "approval_items": [],
        "show_passports_tab": True,
        "show_approvals_mine_all_filter": True,
        "ods_request_source_label": "ОДС",
        "need_sup_hood_modal": False,
        "owned_objects_error": "",
    }
    main = {
        **empty_layers,
        "page_config": {},
        "view_only": False,
        "selected_rootid": "77:04:0001001:12345",
        "selected_source_label": "ДТ",
        "request_id": "240817-001",
        "name": "Детская площадка у дома 12",
    }
    add_object = {
        **empty_layers,
        "page_config": {},
        "effective_request_id": "240817-004",
        "hood_work_area_geojson": {"type": "FeatureCollection", "features": []},
    }
    add_recap = {
        **empty_layers,
        "page_config": {},
        "request_id": "240817-003",
        "name": "Благоустройство дворовой территории",
        "object_key": "(0,1)",
        "selected_rootid": "",
        "selected_source_label": "ОДХ",
        "initial_recap_id": "240817-005",
    }
    approval = {
        "page_title": "Согласование границ ОГХ",
        "page_config": {},
        "map_geojson": None,
        "work_layer_styles": {},
        "svg_index": {},
        "map_message": "",
        "map_error": "",
    }
    login = {"form": AuthenticationForm()}
    return {
        "home.html": ("pass_viewer/home.html", home),
        "main.html": ("pass_viewer/main.html", main),
        "add_object.html": ("pass_viewer/add_object.html", add_object),
        "add_recap.html": ("pass_viewer/add_recap.html", add_recap),
        "approval.html": ("approval/landing.html", approval),
        "login.html": ("registration/login.html", login),
    }


def render_live_pages() -> tuple[dict[str, str], dict[str, str]]:
    """Render the real views against the configured DB without creating a login session."""
    from django.contrib.auth import get_user_model
    from django.contrib.auth.forms import AuthenticationForm
    from django.contrib.sessions.backends.signed_cookies import SessionStore
    from django.test import RequestFactory
    from django.template.loader import render_to_string

    from approval.access import get_accessible_approves, get_owner_id_for_username
    from approval.views import landing
    from pass_viewer.roles import resolve_user_scope
    from pass_viewer.views import (
        _load_home_objects_for_scope,
        add_object,
        add_recap,
        home,
        main,
    )

    users = list(get_user_model().objects.filter(is_active=True).order_by("pk"))
    if not users:
        raise RuntimeError("No active Django users are available for the live export.")

    best_user = None
    best_scope = None
    best_objects: list[dict[str, object]] = []
    best_score = (-1, -1, -1)
    for user in users:
        scope = resolve_user_scope(user.username)
        if scope.role != "BD" or scope.owner_id is None or not scope.can_write:
            continue
        try:
            objects, _ = _load_home_objects_for_scope(scope, has_sup_hood=False)
        except Exception:
            continue
        score = (
            len(objects),
            sum(bool(item.get("rootid")) for item in objects),
            sum(not bool(item.get("rootid")) for item in objects),
        )
        if score > best_score:
            best_user = user
            best_scope = scope
            best_objects = objects
            best_score = score
    if best_user is None or best_scope is None:
        raise RuntimeError("Could not find a writable BD user with an owner scope.")

    passport = next((item for item in best_objects if item.get("rootid")), None)
    request_candidates = [
        item
        for item in best_objects
        if not item.get("rootid") and item.get("object_key") and item.get("request_id")
    ]
    request_candidates.sort(key=lambda item: bool(item.get("is_ods_request")))
    request_item = request_candidates[0] if request_candidates else None
    selected = passport or request_item
    if selected is None:
        raise RuntimeError("The selected live user has no suitable map object.")

    rf = RequestFactory()

    def make_request(path: str, user, *, query=None, session_data=None):
        request = rf.get(path, data=query or {})
        request.user = user
        request.session = SessionStore()
        for key, value in (session_data or {}).items():
            request.session[key] = value
        return request

    def as_html(name: str, response) -> str:
        if response.status_code != 200:
            raise RuntimeError(f"{name} returned HTTP {response.status_code} during live export.")
        return response.content.decode("utf-8")

    entry_point = {
        "rootid": str(selected.get("rootid") or ""),
        "request_id": str(selected.get("request_id") or ""),
        "name": "" if selected.get("rootid") else str(selected.get("name") or ""),
        "source_label": str(selected.get("source_label") or "ДТ"),
        "entry_source": "owned_passport_list" if selected.get("rootid") else "owned_request_list",
        "geometry_detail_mode": "simplified" if selected.get("rootid") else "full",
    }
    pages = {
        "home.html": as_html("home", home(make_request("/", best_user))),
        "main.html": as_html(
            "main",
            main(make_request("/main/", best_user, session_data={"entry_point": entry_point})),
        ),
        "add_object.html": as_html(
            "add_object",
            add_object(make_request("/add-object/", best_user, session_data={"entry_point": entry_point})),
        ),
    }

    recap_response = None
    recap_item = None
    for candidate in request_candidates[:12]:
        query = {
            "request_id": str(candidate.get("request_id") or ""),
            "name": str(candidate.get("name") or ""),
            "object_key": str(candidate.get("object_key") or ""),
            "source_label": str(candidate.get("source_label") or "ДТ"),
            "recap_id": str(candidate.get("request_id") or ""),
        }
        response = add_recap(make_request("/add-recap/", best_user, query=query))
        if response.status_code == 200:
            recap_response = response
            recap_item = candidate
            break
    if recap_response is None:
        raise RuntimeError("Could not render add_recap from the available live request objects.")
    pages["add_recap.html"] = as_html("add_recap", recap_response)

    approval_user = best_user
    approval_count = -1
    for user in users:
        try:
            owner_id = get_owner_id_for_username(user.username)
            count = len(list(get_accessible_approves(owner_id, username=user.username)))
        except Exception:
            continue
        if count > approval_count:
            approval_user = user
            approval_count = count
    pages["approval.html"] = as_html(
        "approval",
        landing(make_request("/approval/", approval_user)),
    )
    pages["login.html"] = render_to_string(
        "registration/login.html", {"form": AuthenticationForm()}
    )

    sample_source = recap_item or request_item or selected
    sample = {
        "request_id": str(sample_source.get("request_id") or ""),
        "rootid": str(sample_source.get("rootid") or selected.get("rootid") or ""),
        "name": str(sample_source.get("name") or selected.get("name") or "Объект городского хозяйства"),
        "source_label": str(sample_source.get("source_label") or "ДТ"),
        "object_count": str(best_score[0]),
        "approval_count": str(max(0, approval_count)),
        "data_mode": "live",
    }
    return pages, sample


def make_standalone(html: str, *, uses_live_data: bool = False) -> str:
    """Replace server-only parts with local assets and a map placeholder."""
    html = SCRIPTS_RE.sub("\n", html)
    html = REMOTE_STYLES_RE.sub("\n", html)
    html = STATIC_URL_RE.sub(r'\1assets/\2\1', html)
    html = LOCAL_LINK_RE.sub('href="#"', html)
    html = LOCAL_ACTION_RE.sub('action="#"', html)
    preview_style = """
<style id="designer-preview-style">
    .designer-preview-notice { margin: 0 0 16px; padding: 10px 14px; border: 1px solid #bfdbfe; border-radius: 8px; background: #eff6ff; color: #1e3a8a; font: 13px/1.4 system-ui, sans-serif; }
    #map, #approval-map { position: relative; overflow: hidden; background-color: #edf2f7; background-image: linear-gradient(30deg, rgba(148, 163, 184, .16) 12%, transparent 12.5%, transparent 87%, rgba(148, 163, 184, .16) 87.5%, rgba(148, 163, 184, .16)), linear-gradient(150deg, rgba(148, 163, 184, .16) 12%, transparent 12.5%, transparent 87%, rgba(148, 163, 184, .16) 87.5%, rgba(148, 163, 184, .16)); background-size: 40px 70px; }
    #map::after, #approval-map::after { content: "Карта — статический макет"; position: absolute; inset: 0; display: grid; place-items: center; color: #475569; font: 600 15px/1.4 system-ui, sans-serif; letter-spacing: .02em; pointer-events: none; }
</style>
"""
    data_label = "Данные получены из локальной БД" if uses_live_data else "Данные обезличены"
    notice = f'<p class="designer-preview-notice"><strong>Статический макет для дизайна.</strong> {data_label}; действия, карта и интеграции отключены.</p>'
    html = html.replace("<main ", preview_style + "<main ", 1)
    main_end = html.find(">", html.find("<main "))
    if main_end != -1:
        html = html[: main_end + 1] + notice + html[main_end + 1 :]
    return html


def extract_element(source: str, start: int, tag: str) -> tuple[str, int]:
    """Return one complete HTML element, accounting for nested equal tags."""
    tag_re = re.compile(rf"</?{re.escape(tag)}\b[^>]*>", re.IGNORECASE)
    depth = 0
    for match in tag_re.finditer(source, start):
        token = match.group(0)
        if token.startswith("</"):
            depth -= 1
            if depth == 0:
                return source[start : match.end()], match.end()
        elif not token.rstrip().endswith("/>"):
            depth += 1
    raise ValueError(f"Unclosed <{tag}> element at position {start}")


def modal_elements(source: str) -> list[tuple[str, str]]:
    """Find top-level modal/dialog blocks from an already rendered preview."""
    candidates: list[tuple[int, int, str, str]] = []
    for match in ELEMENT_RE.finditer(source):
        tag = match.group("tag").lower()
        attrs = match.group("attrs")
        id_match = re.search(r'\bid="([^"]+)"', attrs, re.IGNORECASE)
        element_id = id_match.group(1) if id_match else ""
        if tag != "dialog" and "modal" not in element_id.lower():
            continue
        fragment, end = extract_element(source, match.start(), tag)
        if any(start <= match.start() < existing_end for start, existing_end, _, _ in candidates):
            continue
        candidates.append((match.start(), end, element_id or tag, fragment))
    return [(element_id, fragment) for _, _, element_id, fragment in candidates]


def add_demo_values(fragment: str, sample: dict[str, str]) -> str:
    """Open one modal and fill only its client-rendered empty regions."""
    opening_end = fragment.find(">")
    opening = fragment[: opening_end + 1]
    opening = re.sub(r'\s+hidden(?:="[^"]*")?', "", opening)
    opening = opening.replace("display: none", "display: flex").replace("display:none", "display:flex")
    if opening.lower().startswith("<dialog") and not re.search(r"\sopen(?:\s|>)", opening, re.IGNORECASE):
        opening = opening[:-1] + " open>"
    fragment = opening + fragment[opening_end + 1 :]

    request_id = html_lib.escape(sample.get("request_id") or "—")
    rootid = html_lib.escape(sample.get("rootid") or "—")
    name = html_lib.escape(sample.get("name") or "Объект городского хозяйства")
    source_label = html_lib.escape(sample.get("source_label") or "ДТ")
    approval_count = html_lib.escape(sample.get("approval_count") or "0")
    fragment = re.sub(
        r'(<textarea\b[^>]*>)(\s*)(</textarea>)',
        rf'\1Комментарий по объекту «{name}».\3',
        fragment,
        flags=re.IGNORECASE,
    )

    def text_input_value(match: re.Match[str]) -> str:
        attrs = match.group(1)
        if re.search(r'\bvalue="[^"]+"', attrs, re.IGNORECASE):
            return match.group(0)
        attrs = re.sub(r'\s+value=""', "", attrs, flags=re.IGNORECASE)
        input_id_match = re.search(r'\bid="([^"]+)"', attrs, re.IGNORECASE)
        input_id = input_id_match.group(1).lower() if input_id_match else ""
        if "name" in input_id:
            value = name
        elif "root" in input_id:
            value = rootid
        elif "owner" in input_id or "participant" in input_id:
            value = "00000000-0000-0000-0000-000000000001"
        else:
            value = request_id
        return f'<input{attrs} value="{value}">'

    fragment = re.sub(r'<input\b([^>]*\btype="text"[^>]*)>', text_input_value, fragment, flags=re.IGNORECASE)
    fragment = re.sub(
        r'(<select\b[^>]*>)(\s*)(</select>)',
        rf'\1<option selected>Заявка № {request_id}</option><option>Объект {rootid}</option>\3',
        fragment,
        flags=re.IGNORECASE,
    )
    replacements = {
        "check-dgi-modal-body": (
            f"<p><strong>Проверяемый объект:</strong> {name}</p>"
            f"<p>№ паспорта: {rootid} · источник: {source_label}</p>"
        ),
        "owned-recaps-modal-subtitle": f"Заявка № {request_id} · {name}",
        "owned-recaps-status": "Пример состояния списка досъёмов",
        "owned-recaps-list": (
            f'<div class="owned-list-item"><strong>Досъём по заявке № {request_id}</strong>'
            '<br><span class="note">Демонстрационная строка</span></div>'
        ),
        "dgi-intersections-table-meta": f"Объект: {name}",
        "dgi-intersections-table-status": "Сохранённые результаты пересечений недоступны в текущей локальной БД.",
        "approval-chat-confirm-text": f"Подтвердить действие по заявке № {request_id}?",
        "approval-active-subtitle": f"Заявка № {request_id} · В работе",
        "approval-active-participants": "Состав участников загружается при выборе события.",
        "approval-approval-progress": f"Доступных согласований в выбранном контексте: {approval_count}",
        "approval-message-stats-list": "<li>Статистика появится после выбора события.</li>",
        "approval-db-loading-detail": f"Подготовка данных для объекта «{name}»",
        "owned-view-object-status": f"Объект: {name} · {rootid}",
        "approval-chat-preview-thread": (
            '<div class="approval-chat-message"><strong>Пример:</strong> Сообщение по согласованию границ.</div>'
        ),
        "approval-notifications-feed": (
            f'<li class="approval-notification-item"><strong>Заявка № {request_id}</strong>'
            f'<br><span>{name}</span></li>'
        ),
        "approval-ods-sync-list": (
            f'<li class="approval-notification-item"><strong>АСУ ОДС</strong>'
            f'<br><span>Объект {rootid}</span></li>'
        ),
    }
    for element_id, content in replacements.items():
        pattern = re.compile(
            rf'(<(?:div|p|ul|tbody)\b[^>]*\bid="{re.escape(element_id)}"[^>]*>)(.*?)(</(?:div|p|ul|tbody)>)',
            re.IGNORECASE | re.DOTALL,
        )
        def replace_content(match: re.Match[str]) -> str:
            start = re.sub(r'\s+hidden(?:="[^"]*")?', "", match.group(1))
            start = start.replace("display: none", "display: block").replace("display:none", "display:block")
            return start + content + match.group(3)

        fragment = pattern.sub(replace_content, fragment, count=1)
    fragment = fragment.replace('src="about:blank"', 'src="../main.html"')
    fragment = fragment.replace(
        'id="approval-chat-lightbox-img" alt=""',
        'id="approval-chat-lightbox-img" src="../assets/pass_viewer/brand-mark.png" alt="Демонстрационное изображение"',
    )
    fragment = fragment.replace('class="dgi-intersections-table-wrap" hidden', 'class="dgi-intersections-table-wrap"')
    fragment = re.sub(
        r'(<section\b[^>]*\bid="approval-(?:notifications-approvals|ods-sync)-section"[^>]*)\s+hidden([^>]*>)',
        r"\1\2",
        fragment,
        flags=re.IGNORECASE,
    )
    return fragment


def modal_title(fragment: str, fallback: str) -> str:
    match = HEADING_RE.search(fragment)
    if not match:
        return fallback
    text = re.sub(r"<[^>]+>", "", match.group(1))
    return html_lib.unescape(text).strip() or fallback


def write_modal_previews(output_dir: Path, sample: dict[str, str]) -> None:
    """Export each dialog inside its complete source page to preserve layout context."""
    modal_dir = output_dir / "modals"
    if modal_dir.exists():
        shutil.rmtree(modal_dir)
    modal_dir.mkdir()
    index_rows: list[tuple[str, str, str]] = []
    for source_page in sorted(output_dir.glob("*.html")):
        source = source_page.read_text(encoding="utf-8")
        for element_id, fragment in modal_elements(source):
            slug = re.sub(r"[^a-z0-9]+", "-", element_id.lower()).strip("-")
            filename = f"{source_page.stem}--{slug}.html"
            title = modal_title(fragment, element_id)
            page = source.replace(fragment, add_demo_values(fragment, sample), 1)
            page = page.replace('href="assets/', 'href="../assets/').replace(
                'src="assets/', 'src="../assets/'
            )
            if fragment.lstrip().lower().startswith("<dialog"):
                dialog_script = (
                    f'<script>const previewDialog=document.getElementById({element_id!r});'
                    "if(previewDialog){previewDialog.removeAttribute('open');previewDialog.showModal();}</script>"
                )
                page = page.replace("</body>", dialog_script + "</body>", 1)
            (modal_dir / filename).write_text(page, encoding="utf-8")
            index_rows.append((filename, title, source_page.stem))
    links = "\n".join(
        f'<li><a href="{filename}">{html_lib.escape(title)}</a><span>{html_lib.escape(source)}</span></li>'
        for filename, title, source in index_rows
    )
    data_description = (
        "Данные страниц получены из локальной БД."
        if sample.get("data_mode") == "live"
        else "Значения обезличены, но соответствуют форматам полей приложения."
    )
    (modal_dir / "index.html").write_text(
        f"""<!doctype html><html lang="ru"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Модальные окна</title><style>body{{max-width:900px;margin:32px auto;padding:0 20px;font:15px/1.45 system-ui,sans-serif;color:#1e293b}}h1{{margin-bottom:4px}}ul{{padding:0;list-style:none;display:grid;gap:8px}}li{{display:flex;justify-content:space-between;gap:20px;padding:12px 14px;border:1px solid #d8e0ea;border-radius:8px}}a{{color:#1d4ed8;font-weight:600;text-decoration:none}}span{{color:#64748b;font-size:13px}}</style></head><body><h1>Модальные окна</h1><p>Окна показаны внутри полных страниц приложения, поэтому наследуют исходное позиционирование и размеры. {data_description}</p><ul>{links}</ul></body></html>""",
        encoding="utf-8",
    )


def copy_assets(output_dir: Path) -> None:
    source = PROJECT_DIR / "staticfiles"
    destination = output_dir / "assets"
    required_assets = [
        "pass_viewer/brand-mark.png",
        "pass_viewer/css/base.css",
        "pass_viewer/css/tokens.css",
        "pass_viewer/css/map-core.css",
        "pass_viewer/css/map-toolbar.css",
        "pass_viewer/css/map-layers.css",
        "pass_viewer/css/map-editor.css",
        "pass_viewer/css/home.css",
        "approval/css/landing.css",
    ]
    for asset in required_assets:
        target = destination / asset
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source / asset, target)


def export(output_dir: Path, *, use_live_db: bool = False) -> None:
    if str(PROJECT_DIR) not in sys.path:
        sys.path.insert(0, str(PROJECT_DIR))
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "pass_map.settings")
    import django
    from django.template import Context, loader

    django.setup()
    output_dir.mkdir(parents=True, exist_ok=True)
    copy_assets(output_dir)
    if use_live_db:
        rendered_pages, sample = render_live_pages()
    else:
        rendered_pages = {}
        for filename, (template_name, context) in page_contexts().items():
            rendered_pages[filename] = loader.get_template(template_name).template.render(
                Context({**context, "csrf_token": "static-preview"})
            )
        sample = {
            "request_id": "240817-003",
            "rootid": "77:04:0001001:12345",
            "name": "Демонстрационный объект",
            "source_label": "ДТ",
            "object_count": str(len(SAMPLE_OBJECTS)),
            "approval_count": "0",
            "data_mode": "mock",
        }
    for filename, rendered in rendered_pages.items():
        (output_dir / filename).write_text(
            make_standalone(rendered, uses_live_data=use_live_db), encoding="utf-8"
        )
    write_modal_previews(output_dir, sample)
    (output_dir / "README.txt").write_text(
        "Откройте любой HTML-файл двойным щелчком в браузере.\n"
        "Все страницы используют локальные стили из папки assets и не требуют Django, БД или интернета.\n"
        "Страница авторизации: login.html.\n"
        "Модальные окна: modals/index.html. Каждое окно открывается отдельным HTML-файлом.\n",
        encoding="utf-8",
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Export standalone designer previews.")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT, help="Output directory")
    parser.add_argument(
        "--live-db",
        action="store_true",
        help="Render real configured database content into the shareable HTML bundle.",
    )
    args = parser.parse_args()
    export(args.output.resolve(), use_live_db=args.live_db)
    print(f"Designer preview exported to {args.output.resolve()}")


if __name__ == "__main__":
    main()
