from django.apps import AppConfig


class ApprovalConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "approval"

    def ready(self):
        from django.db.models.signals import post_save

        from .models import Approve, Case

        def create_primary_case(sender, instance, created, **kwargs):
            if not created:
                return
            if instance.cases.filter(is_primary=True).exists():
                return
            Case.objects.create(
                approve=instance,
                is_primary=True,
                title="Основное событие",
                status="в работе",
                n_root=None,
                owners=[],
            )

        post_save.connect(create_primary_case, sender=Approve)
