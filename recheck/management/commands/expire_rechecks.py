from django.core.management.base import BaseCommand

from recheck.services import expire_due_events


class Command(BaseCommand):
    help = "Закрывает просроченные проверки геоподосновы"

    def handle(self, *args, **options):
        count = expire_due_events()
        self.stdout.write(self.style.SUCCESS(f"Закрыто проверок: {count}"))
