#!/usr/bin/env bash
# Fenced-block sanity — the defect markdownlint cannot see.
# An even number of ``` markers lints clean while meaning the opposite of what
# the author intended. At 0.33.0 an orphan fence swallowed 224 lines of W as
# code and every check passed. This reads the fences semantically instead.
#
# Tiers, following the ledger's precedent: an UNCLOSED fence is BLOCKING, because
# it always means the document renders as something other than it says. A LONG
# SPAN is INFORMATIONAL — H·6 carries a legitimate 62-line schema, and a stop
# that fires on that gets ignored when it fires on a real one.
#
#   exit 0  clean or informational only      exit 1  unclosed fence      exit 3  usage
set -euo pipefail
ROOT="${1:-$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)}"
[ -d "$ROOT" ] || { echo "fence-check: not a directory: $ROOT" >&2; exit 3; }
python3 - "$ROOT" <<'PY'
import glob, os, sys
root = sys.argv[1]
MAX = 60          # a genuine code block longer than this is worth a human look
bad = noted = files = 0
for f in sorted(glob.glob(os.path.join(root, "*.md"))):
    files += 1
    lines = open(f, encoding="utf-8").read().split("\n")
    inside, start = False, None
    for n, l in enumerate(lines, 1):
        if l.strip().startswith("```"):
            if not inside:
                inside, start = True, n
            else:
                inside = False
                if n - start > MAX:
                    print("  long span  %-46s lines %d-%d (%d) — informational"
                          % (os.path.basename(f)[:46], start, n, n - start)); noted += 1
    if inside:
        print("  UNCLOSED   %-46s opens at line %d, never closes"
              % (os.path.basename(f)[:46], start)); bad += 1
print("fence-check: %d files, %d unclosed, %d long span(s) noted" % (files, bad, noted))
if bad:
    print("\nSTOP. An unclosed fence means the document renders as something other "
          "than it says, and a balanced count does not prove otherwise.")
    raise SystemExit(1)
print("CLEAN — every fenced span closes.")
PY
