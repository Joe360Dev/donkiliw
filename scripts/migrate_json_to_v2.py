#!/usr/bin/env python3
"""
Migrates JSON hymn books from the old string-per-section format
to the new array-of-phrase-groups format (v2).

Old format:
    { "couple": "Line 1\n: Line 2 : (2x)\nLine 3" }

New format:
    { "couple": [
        { "lines": ["Line 1"],  "repeat": 1 },
        { "lines": ["Line 2"],  "repeat": 2 },
        { "lines": ["Line 3"],  "repeat": 1 }
    ]}

RULES applied during migration:
  - ALL repeats are treated as PHRASE-LEVEL (each group has exactly 1 line).
  - The `: text : (Nx)` block notation is parsed: every line inside the
    block gets repeat=N individually.
  - Inline `(Nx)` on a plain line (without surrounding colons) → that line
    gets repeat=N.
  - Lines with no repeat notation → repeat=1.
  - Leading/trailing colons and whitespace are stripped from line content.
  - "titre" sections and top-level "autrepassage" keys are left untouched.
  - Group-level repeat promotion is left for manual editing.

Usage:
    cd /path/to/donkiliw
    python3 scripts/migrate_json_to_v2.py
"""

import json
import re
import os
import shutil

# ─── Config ────────────────────────────────────────────────────────────────────
JSON_DIR = "assets/json_books/"

# Which books to migrate in this run (add more when ready)
BOOKS_TO_MIGRATE = [
    "betiba.json",
]

# ─── Regexes ───────────────────────────────────────────────────────────────────
# Matches a complete single-line block:  ": text : (Nx)"
_RE_SINGLE_BLOCK = re.compile(
    r"^\s*:\s+(.*?)\s*:\s*\((\d+)x\)\s*$", re.UNICODE
)
# Matches: end of a multi-line block  "text : (Nx)"
_RE_BLOCK_END = re.compile(
    r"^(.*?)\s*:\s*\((\d+)x\)\s*$", re.UNICODE
)
# Matches: start of a multi-line block  ": text..."  (no closing : (Nx) yet)
_RE_BLOCK_START = re.compile(
    r"^\s*:\s+\S", re.UNICODE
)
# Matches: inline repeat on a plain line  "text (Nx)"
_RE_INLINE_REPEAT = re.compile(
    r"^(.*?)\s*\((\d+)x\)\s*$", re.UNICODE
)
# Strip leading/trailing colons and whitespace from content
_RE_STRIP_COLONS = re.compile(
    r"^[:\s]+|[:\s]+$", re.UNICODE
)


# ─── Parser ────────────────────────────────────────────────────────────────────
def parse_section_content(raw: str) -> list:
    """
    Convert a section content string into a list of phrase-group dicts.

    Each group:  { "lines": [str], "repeat": int }
    For now every group has exactly one line (phrase-level).
    """
    groups = []
    in_block = False
    block_lines: list[str] = []
    block_repeat = 1

    for raw_line in raw.split("\n"):
        line = raw_line.strip()
        if not line:
            continue

        # ── Case 1: complete single-line block  ": text : (Nx)" ──────────────
        m = _RE_SINGLE_BLOCK.match(line)
        if m:
            content = m.group(1).strip()
            repeat = int(m.group(2))
            if content:
                groups.append({"lines": [content], "repeat": repeat})
            continue

        # ── Case 2: start of a multi-line block  ": text..." ─────────────────
        if not in_block and _RE_BLOCK_START.match(line):
            in_block = True
            content = _RE_STRIP_COLONS.sub("", line).strip()
            block_lines = [content] if content else []
            block_repeat = 1
            continue

        # ── Case 3: inside a block ────────────────────────────────────────────
        if in_block:
            m = _RE_BLOCK_END.match(line)
            if m:
                # This line closes the block
                content = m.group(1).strip()
                block_repeat = int(m.group(2))
                if content:
                    block_lines.append(content)
                # Flush every line in the block as its own phrase-level group
                for bl in block_lines:
                    bl = _RE_STRIP_COLONS.sub("", bl).strip()
                    if bl:
                        groups.append({"lines": [bl], "repeat": block_repeat})
                in_block = False
                block_lines = []
                block_repeat = 1
            else:
                block_lines.append(line)
            continue

        # ── Case 4: plain line with inline (Nx) ──────────────────────────────
        m = _RE_INLINE_REPEAT.match(line)
        if m:
            content = _RE_STRIP_COLONS.sub("", m.group(1)).strip()
            repeat = int(m.group(2))
            if content:
                groups.append({"lines": [content], "repeat": repeat})
            continue

        # ── Case 5: regular line ─────────────────────────────────────────────
        content = _RE_STRIP_COLONS.sub("", line).strip()
        if content:
            groups.append({"lines": [content], "repeat": 1})

    # Flush an unclosed block (shouldn't happen in well-formed data)
    if in_block and block_lines:
        for bl in block_lines:
            bl = _RE_STRIP_COLONS.sub("", bl).strip()
            if bl:
                groups.append({"lines": [bl], "repeat": block_repeat})

    return groups


# ─── Migrator ──────────────────────────────────────────────────────────────────
SECTION_CONTENT_KEYS = {"couple", "refrain"}  # Keys whose values get migrated


def migrate_hymn(hymn: dict) -> dict:
    """Migrate a single hymn dict in-place and return it."""
    new_content = []
    for section in hymn.get("content", []):
        new_section = {}
        for key, value in section.items():
            if key in SECTION_CONTENT_KEYS and isinstance(value, str):
                new_section[key] = parse_section_content(value)
            else:
                # titre, autrepassage, or already-migrated values → keep as-is
                new_section[key] = value
        new_content.append(new_section)
    hymn["content"] = new_content
    return hymn


def migrate_book(json_path: str) -> None:
    """Back up and migrate a single JSON hymn book."""
    # 1. Backup
    backup_path = json_path + ".bak"
    shutil.copy2(json_path, backup_path)
    print(f"  ✓ Backup → {backup_path}")

    # 2. Load
    with open(json_path, "r", encoding="utf-8") as f:
        hymns = json.load(f)

    # 3. Migrate
    migrated = [migrate_hymn(h) for h in hymns]

    # 4. Write
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(migrated, f, ensure_ascii=False, indent=2)

    print(f"  ✓ Migrated → {json_path}  ({len(migrated)} hymns)")


# ─── Main ──────────────────────────────────────────────────────────────────────
def main():
    for book_file in BOOKS_TO_MIGRATE:
        json_path = os.path.join(JSON_DIR, book_file)
        if not os.path.exists(json_path):
            print(f"  ✗ Not found: {json_path}")
            continue
        print(f"\nMigrating: {book_file}")
        migrate_book(json_path)

    print("\nDone.")


if __name__ == "__main__":
    main()
