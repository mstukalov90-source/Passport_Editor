from django.apps import AppConfig


class RecheckConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "recheck"

    def ready(self):
        from django.db.models.signals import post_save

        from approval.models import Approve

        from .services import create_recheck_for_approved

        def enqueue_recheck(sender, instance, **kwargs):
            if instance.approved:
                create_recheck_for_approved(instance)

        post_save.connect(
            enqueue_recheck,
            sender=Approve,
            dispatch_uid="recheck.enqueue_approved_approve",
        )
