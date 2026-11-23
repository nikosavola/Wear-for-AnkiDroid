#!/usr/bin/env python3
"""Build the demo .apkg used for Play review and screenshots.

Run with `uv run --with anki scripts/make-demo-deck.py`. The package is written by Anki's own
exporter, so AnkiDroid imports it like any other collection. Import the result into AnkiDroid, then
sync to the watch.
"""

from pathlib import Path
from tempfile import TemporaryDirectory

from anki.collection import Collection, ExportAnkiPackageOptions

OUT = (
    Path(__file__).resolve().parent.parent
    / "docs"
    / "demo"
    / "wear-for-ankidroid-demo.apkg"
)

DECKS = {
    "Spanish": [
        ("la manzana", "the apple"),
        ("el libro", "the book"),
        ("la ventana", "the window"),
        ("el río", "the river"),
        ("la ciudad", "the city"),
        ("aprender", "to learn"),
    ],
    "Japanese": [
        ("本 (ほん)", "book"),
        ("水 (みず)", "water"),
        ("山 (やま)", "mountain"),
        ("友達 (ともだち)", "friend"),
        ("食べる (たべる)", "to eat"),
        ("大きい (おおきい)", "big"),
    ],
    "World Capitals": [
        ("Finland", "Helsinki"),
        ("Japan", "Tokyo"),
        ("Brazil", "Brasília"),
        ("Kenya", "Nairobi"),
        ("Canada", "Ottawa"),
        ("Australia", "Canberra"),
    ],
}


def main() -> None:
    with TemporaryDirectory() as temp:
        collection = Collection(str(Path(temp) / "demo.anki2"))
        try:
            model = collection.models.by_name("Basic")
            for name, cards in DECKS.items():
                deck_id = collection.decks.id(name)
                for front, back in cards:
                    note = collection.new_note(model)
                    note["Front"] = front
                    note["Back"] = back
                    collection.add_note(note, deck_id)
            OUT.parent.mkdir(parents=True, exist_ok=True)
            collection.export_anki_package(
                out_path=str(OUT),
                options=ExportAnkiPackageOptions(
                    with_scheduling=True,
                    with_deck_configs=True,
                    with_media=True,
                ),
                limit=None,
            )
        finally:
            collection.close()
    print(f"wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
