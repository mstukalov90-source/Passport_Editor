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
            if not instance.cases.filter(is_primary=True).exists():
                Case.objects.create(
                    approve=instance,
                    is_primary=True,
                    title="Основное событие",
                    status="в работе",
                    n_root=None,
                    owners=[],
                )
            Case.objects.get_or_create(
                approve=instance,
                event_type=Case.TYPE_SURFACE_JUNCTION,
                defaults={
                    "is_primary": False,
                    "title": "Согласование элементов сопряжения поверхностей",
                    "status": "в работе",
                    "n_root": None,
                    "owners": list(instance.owners or []),
                },
            )

        post_save.connect(create_primary_case, sender=Approve)
