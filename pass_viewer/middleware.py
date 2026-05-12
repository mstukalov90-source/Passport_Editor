from pass_viewer.hood_scope import clear_hood_scope, resolve_and_bind_hood_scope


class HoodSpatialScopeMiddleware:
    """Binds per-request hood spatial scope for authenticated users (see hood_scope.py)."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        resolve_and_bind_hood_scope(request)
        try:
            return self.get_response(request)
        finally:
            clear_hood_scope()
