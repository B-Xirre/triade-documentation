#!/usr/bin/env bash
# Version alignment check — Triade design set
#
# Asserts that every CURRENT-STATE version claim in the corpus matches
# VERSION-MANIFEST.md. Historical claims are ignored by construction: this
# only reads lines that assert what is true *now*.
#
# WHY THIS EXISTS. Version sweeps at a bump match a handful of patterns —
# `**Version:** 0.x.0` and `**Version 0.x.0**`. Everything else drifts silently:
#   V's footer read 0.10.0 for seven releases.
#   K's footer read 0.12.0 for four.
#   The design-stream instructions read "aligned to 0.23.0" while the set was
#   at 0.25.0, because "aligned to design set" matches no sweep pattern.
# Each was found by eye, late. This finds them on demand.
#
# Usage:  tools/version-check.sh [root]
# Exit:   0 aligned · 1 drift found · 3 root error

set -euo pipefail
ROOT="${1:-$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)}"
[ -d "$ROOT" ] || { echo "version-check: not a directory: $ROOT" >&2; exit 3; }

python3 - "$ROOT" <<'PY'
import glob, os, re, sys

root = os.path.realpath(sys.argv[1])
man = os.path.join(root, "VERSION-MANIFEST.md")
if not os.path.exists(man):
    sys.exit("version-check: no VERSION-MANIFEST.md")

m = re.search(r'\*\*Current version:\*\*\s*(\d+\.\d+\.\d+)', open(man, encoding="utf-8").read())
if not m:
    sys.exit("version-check: manifest states no current version")
cur = m.group(1)

# Patterns that assert CURRENT state. Each must carry the current version.
CLAIMS = [
    ("version header",     re.compile(r'(?m)^\*\*Version:?\*{0,2}:?\s*(\d+\.\d+\.\d+)')),
    ("version header",     re.compile(r'(?m)^\*\*Version (\d+\.\d+\.\d+)\*\*')),
    ("aligned-to line",    re.compile(r'aligned to design set \*\*v(\d+\.\d+\.\d+)\*\*')),
    ("closing line",       re.compile(r'(?m)^\*End of [A-Za-z ]+ (\d+\.\d+\.\d+)')),
    ("status line",        re.compile(r'\*\*Status:\*\* Regenerated at (\d+\.\d+\.\d+)')),
    ("manifest footer",    re.compile(r'\*Manifest current as of (\d+\.\d+\.\d+)')),
    ("progress line",      re.compile(r'\((\d+\.\d+\.\d+)-aligned\)')),
    ("content_version",    re.compile(r'rows authored against the current set use `(\d+\.\d+\.\d+)`')),
    ("sources-consumed",   re.compile(r'All at \*\*(\d+\.\d+\.\d+)\*\*, from Drive folder')),
    ("aligned-to-triade",  re.compile(r'\*\*Aligned to Triade:\*\* v(\d+\.\d+\.\d+)')),
]
# Documents authored by another stream are REPORTED, never edited here. Their drift
# warns and does not affect the exit code: central raises a counter-patch instead.
# 0.30.0: this was an EXEMPT entry naming a label no pattern produced, so the claim
# was never read at all. A check that cannot fail has not run.
# 0.36.0: C joined the set. Central had been repointing a stream-owned document's
# version headers every bump without a stream replacement behind it — reporting an
# alignment that nobody had actually performed.
WARN_ONLY = {"Z-Technical_Stream_Project_Instructions",
             "C-Content_Authoring_Technical_Specification"}  # 0.36.0: both stream-owned

drift, warn, checked = [], [], 0
for f in sorted(glob.glob(os.path.join(root, "*.md"))):
    name = os.path.basename(f)
    txt = open(f, encoding="utf-8").read()
    for label, pat in CLAIMS:
        for mm in pat.finditer(txt):
            checked += 1
            if mm.group(1) != cur:
                line = txt[:mm.start()].count("\n") + 1
                if any(name.startswith(k) for k in WARN_ONLY):
                    warn.append((name, line, label, mm.group(1)))
                else:
                    drift.append((name, line, label, mm.group(1)))

print("version-check: %d current-state claims against manifest %s" % (checked, cur))
for name, line, label, got in warn:
    print("  WARN   %-52s :%-5d %-18s says %s — stream-authored; raise a counter-patch"
          % (name[:52], line, label, got))
if not drift:
    print("ALIGNED — every current-state version claim matches the manifest.")
    raise SystemExit(0)
for name, line, label, got in drift:
    print("  DRIFT  %-52s :%-5d %-16s says %s" % (name[:52], line, label, got))
print("\nSTOP. %d current-state claim(s) name a version the set has left behind." % len(drift))
raise SystemExit(1)
PY
