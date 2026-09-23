#!/usr/bin/env python3
import json
import os
import re
import shlex
import sys
from pathlib import Path

PROJECT_DIR = Path(
    os.environ.get("CLAUDE_PROJECT_DIR") or Path(__file__).resolve().parents[2]
)
FIX_MODE_MARKER = PROJECT_DIR / ".claude" / "fix-mode"

# Commandes shell capables de modifier ou supprimer un fichier qu'elles citent.
SHELL_WRITE_PATTERN = re.compile(
    r"\bsed\s+(-\S*\s+)*-i|\bperl\s+(-\S*\s+)*-i|\brm\b|\bmv\b|\bcp\b"
    r"|\btruncate\b|\bdd\b|\bunlink\b|\bgit\s+(checkout|restore|rm|mv)\b"
)
# Cibles d'une redirection (> fichier, >> fichier) ou de tee.
SHELL_OUTPUT_TARGET = re.compile(r">>?\s*([^\s&|;<>]+)|\btee\s+(?:-\S+\s+)*([^\s|;<>]+)")

REFUSAL_MESSAGE = (
    "Les fichiers de tests sont protégés pendant une correction. "
    "Corrige le code, pas le test."
)


def is_test_path(path):
    parts = Path(path).parts
    return "tests" in parts[:-1] or os.path.basename(path).startswith("test_")


def targets_test_file(tool_name, tool_input):
    if tool_name == "Bash":
        command = tool_input.get("command", "")
        try:
            words = shlex.split(command)
        except ValueError:
            words = command.split()
        mentions_test = any(is_test_path(word) for word in words)
        writes_test = any(
            is_test_path(target)
            for match in SHELL_OUTPUT_TARGET.finditer(command)
            for target in match.groups()
            if target
        )
        return writes_test or (
            mentions_test and bool(SHELL_WRITE_PATTERN.search(command))
        )
    path = tool_input.get("file_path") or tool_input.get("notebook_path") or ""
    return is_test_path(path)


data = json.load(sys.stdin)
if FIX_MODE_MARKER.exists() and targets_test_file(
    data.get("tool_name", ""), data.get("tool_input", {})
):
    print(REFUSAL_MESSAGE, file=sys.stderr)
    sys.exit(2)
sys.exit(0)
