from django.core.management.base import BaseCommand

from approval.qml_style_builder import build_manifest, load_svg_index, write_manifest


class Command(BaseCommand):
    help = "Generate work_layer_styles.json manifest from QML sources."

    def add_arguments(self, parser):
        parser.add_argument(
            "--no-svg",
            action="store_true",
            help="Skip syncing SVG icons into static files.",
        )

    def handle(self, *args, **options):
        manifest = build_manifest()
        path = write_manifest(manifest, copy_svgs=not options["no_svg"])
        table_count = len(manifest.get("tables", {}))
        svg_count = 0
        if not options["no_svg"]:
            svg_count = len(set(load_svg_index().values()))
        self.stdout.write(
            self.style.SUCCESS(
                f"Wrote {path} ({table_count} tables, {svg_count} svg files synced)"
            )
        )
