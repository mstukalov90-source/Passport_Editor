import logging

from pass_viewer.hood_scope import clear_hood_scope, resolve_and_bind_hood_scope

logger = logging.getLogger(__name__)


class HoodSpatialScopeMiddleware:
    """Binds per-request hood spatial scope for authenticated users (see hood_scope.py)."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        try:
            resolve_and_bind_hood_scope(request)
        except Exception:
            logger.exception("HoodSpatialScopeMiddleware: bind failed")
            try:
                clear_hood_scope()
            except Exception:
                pass
        try:
            return self.get_response(request)
        finally:
            clear_hood_scope()
