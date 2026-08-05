"""User roles for pass_viewer / approval access scope."""

from __future__ import annotations

from dataclasses import dataclass

from pass_viewer.models import ExternalUser

ROLE_BD = "BD"
ROLE_MGGT = "MGGT"
ROLE_DEP = "DEP"
ROLE_DEP_PLUS = "DEP+"
ROLE_SUP = "SUP"

VALID_ROLES = frozenset({ROLE_BD, ROLE_MGGT, ROLE_DEP, ROLE_DEP_PLUS, ROLE_SUP})

# Session key for SUP selected hood district (public.hood.gid).
SUP_HOOD_SESSION_GID = "sup_hood_gid"
SUP_HOOD_SESSION_LABEL = "sup_hood_label"

FILTER_OWNER = "owner"
FILTER_OWNER_MULTI = "owner_multi"
FILTER_DEPARTMENT = "department"
FILTER_NONE = "none"
FILTER_HOOD = "hood"

APPROVALS_OWNED = "owned"
APPROVALS_ALL = "all"


@dataclass(frozen=True)
class UserScope:
    role: str
    owner_id: str | None
    owner_ids: tuple[str, ...]
    filter_field: str
    can_write: bool
    is_global_inspector: bool
    approvals_mode: str
    include_ods: bool
    username: str
    display_name: str = ""

    @property
    def needs_sup_hood(self) -> bool:
        return self.role == ROLE_SUP


def normalize_role(value: str | None) -> str:
    role = str(value or "").strip().upper()
    if role in VALID_ROLES:
        return role
    return ROLE_BD


def _normalize_owner_ids(raw) -> tuple[str, ...]:
    if not raw:
        return ()
    out: list[str] = []
    seen: set[str] = set()
    for item in raw:
        text = str(item).strip()
        if not text or text in seen:
            continue
        seen.add(text)
        out.append(text)
    return tuple(out)


def get_external_user(username: str | None) -> ExternalUser | None:
    if not username:
        return None
    login = str(username).strip()
    if not login:
        return None
    return (
        ExternalUser.objects.filter(login=login)
        .only(
            "login",
            "owner_legal_person_id",
            "owner_legal_person_ids",
            "display_name",
            "hood_scope",
            "role",
        )
        .first()
    )


def get_user_role(username: str | None) -> str:
    user = get_external_user(username)
    if user is None:
        return ROLE_BD
    return normalize_role(getattr(user, "role", None))


def resolve_user_scope(username: str | None) -> UserScope:
    login = str(username or "").strip()
    user = get_external_user(login)
    owner_raw = user.owner_legal_person_id if user else None
    owner_id = str(owner_raw).strip() if owner_raw else None
    if owner_id == "":
        owner_id = None
    role = normalize_role(getattr(user, "role", None) if user else None)
    multi_ids = _normalize_owner_ids(getattr(user, "owner_legal_person_ids", None) if user else None)
    display_name = ""

    if role == ROLE_MGGT:
        return UserScope(
            role=role,
            owner_id=owner_id,
            owner_ids=(),
            filter_field=FILTER_NONE,
            can_write=True,
            is_global_inspector=True,
            approvals_mode=APPROVALS_ALL,
            include_ods=False,
            username=login,
        )
    if role == ROLE_DEP:
        return UserScope(
            role=role,
            owner_id=owner_id,
            owner_ids=(owner_id,) if owner_id else (),
            filter_field=FILTER_DEPARTMENT,
            can_write=True,
            is_global_inspector=False,
            approvals_mode=APPROVALS_OWNED,
            include_ods=True,
            username=login,
        )
    if role == ROLE_DEP_PLUS:
        display_name = str(getattr(user, "display_name", "") or "").strip() if user else ""
        return UserScope(
            role=role,
            owner_id=multi_ids[0] if multi_ids else None,
            owner_ids=multi_ids,
            filter_field=FILTER_OWNER_MULTI,
            can_write=True,
            is_global_inspector=False,
            approvals_mode=APPROVALS_OWNED,
            include_ods=True,
            username=login,
            display_name=display_name,
        )
    if role == ROLE_SUP:
        return UserScope(
            role=role,
            owner_id=owner_id,
            owner_ids=(),
            filter_field=FILTER_HOOD,
            can_write=False,
            is_global_inspector=False,
            approvals_mode=APPROVALS_ALL,
            include_ods=False,
            username=login,
        )
    # BD (default)
    return UserScope(
        role=ROLE_BD,
        owner_id=owner_id,
        owner_ids=(owner_id,) if owner_id else (),
        filter_field=FILTER_OWNER,
        can_write=True,
        is_global_inspector=False,
        approvals_mode=APPROVALS_OWNED,
        include_ods=True,
        username=login,
    )


def sees_all_approvals(scope: UserScope) -> bool:
    return scope.approvals_mode == APPROVALS_ALL


def is_mggt(scope: UserScope | str | None) -> bool:
    if isinstance(scope, UserScope):
        return scope.role == ROLE_MGGT
    return normalize_role(scope) == ROLE_MGGT


def is_sup(scope: UserScope | str | None) -> bool:
    if isinstance(scope, UserScope):
        return scope.role == ROLE_SUP
    return normalize_role(scope) == ROLE_SUP
