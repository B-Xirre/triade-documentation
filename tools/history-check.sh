#!/usr/bin/env bash
# History integrity check — Triade design set
#
# Rule P-C11: the FACTUAL CLAIMS of a historical changelog row or release summary
# — counts, severity splits, "N of M" figures — may not be altered by a version
# sweep. A bump touches current-state assertions only.
#
# NOTATION IS EXEMPT, AND DELIBERATELY SO. Filenames are repointed so links
# resolve; identifiers gained glyphs at 0.18.0; section refs were normalised at
# 0.19.0. Those migrations are applied retroactively on purpose. A first draft of
# this check compared raw text and returned 71 hits, nearly all of them policy —
# a check that fires on noise gets ignored on signal.
#
# WHY THIS EXISTS. Between 0.19.0 and 0.21.0 blanket replacements of the form
# s/139 rules/142 rules/ were applied across all files to advance current
# figures. They also hit changelog rows and release summaries, so five rows and
# eight summary claims asserted counts that were never true when written. The
# archives were the only surviving record. The rule forbidding this had existed
# in prose since 0.12.0 with nothing to enforce it.
#
# Usage:
#   tools/history-check.sh [docroot] [archiveroot]
#
# Exit: 0 clean · 1 history altered · 3 usage/root error
#
# Compares every changelog row and release summary in every archived version
# against its live counterpart, keyed by version. Whitespace and table padding
# are normalised; anything else is a violation.

set -euo pipefail
DOC="${1:-$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)}"
ARC="${2:-$DOC/../Documentation-Archive/Archive}"
[ -d "$DOC" ] || { echo "history-check: not a directory: $DOC" >&2; exit 3; }
[ -d "$ARC" ] || { echo "history-check: no archive at: $ARC" >&2; exit 3; }

python3 - "$DOC" "$ARC" <<'PY'
import os, re, sys, glob, collections

doc, arc = os.path.realpath(sys.argv[1]), os.path.realpath(sys.argv[2])
VER = re.compile(r'-\d+_\d+_\d+(?=\.md$)')
ROW = re.compile(r'(?m)^\|\s*\*{0,2}(\d+\.\d+\.\d+)\*{0,2}[^|]*\|(.*)$')
SUM = re.compile(r'(?s)##\s+(\d+\.\d+\.\d+)\s+release summary(.*?)(?=\n##\s|\Z)')
# factual claims only — counts, splits, N-of-M
FACT = re.compile(r'\b\d{2,3} */ *\d{2,3} */ *\d{2,3}\b'
                  r'|\b\d{1,3} of \d{2,3}\b'
                  r'|\b\d{2,3} rules\b'
                  r'|\b\d{2,3} Critical / \d{2,3} High / \d{2,3} Medium\b'
                  r'|Suite \d+ → \d+'
                  r'|= \d{2,3}\b')

REF    = re.compile(r'^[A-Z0-9]{1,2}-')      # 0.22.0 ref prefix:  K-, B-, 00-
PREFIX = re.compile(r'^TRIADE-')             # pre-0.22.0 form
SUFFIX = re.compile(r'_TRIADE(?=\.|$)')      # 0.22.0 form


def stem(p):
    """A name that survives the 0.22.0 rename, so archive and live still pair up.

    Before 0.22.0:  TRIADE-Combat_design-0_21_0.md
    After:          K-Combat_design_TRIADE-0_22_0.md
    Both reduce to: Combat_design

    Without this the two share no key, every archived entry loses its
    counterpart, and the check compares ZERO pairs while reporting CLEAN —
    a check that cannot fail has not run.
    """
    n = VER.sub("", os.path.basename(p))
    n = n[:-3] if n.endswith(".md") else n
    n = REF.sub("", n)
    n = PREFIX.sub("", n)
    n = SUFFIX.sub("", n)
    return n

def facts(s):           # the claims that may not change
    return FACT.findall(s)

live = {stem(p): p for p in glob.glob(os.path.join(doc, "*.md"))}
violations, checked = [], 0
seen_row = set()        # compare against the EARLIEST archive holding a row;
                        # later archives may already carry the corruption

for vdir in sorted(os.listdir(arc), key=lambda v: [int(re.sub(r"\D.*$","",x) or 0) for x in v.lstrip("v").split(".")]):
    ap = os.path.join(arc, vdir)
    if not os.path.isdir(ap):
        continue
    for af in glob.glob(os.path.join(ap, "*.md")):
        lp = live.get(stem(af))
        if not lp:
            continue
        a, l = open(af, encoding="utf-8").read(), open(lp, encoding="utf-8").read()
        for kind, pat in (("changelog row", ROW), ("release summary", SUM)):
            av = {m.group(1): m.group(2) for m in pat.finditer(a)}
            lv = {m.group(1): m.group(2) for m in pat.finditer(l)}
            for ver in sorted(set(av) & set(lv)):
                key = (stem(af), kind, ver)
                if key in seen_row:
                    continue
                seen_row.add(key)
                checked += 1
                fa, fl = facts(av[ver]), facts(lv[ver])
                if fa != fl:
                    violations.append((os.path.basename(lp), kind, ver, vdir,
                                       ", ".join(fa) or "(none)",
                                       ", ".join(fl) or "(none)"))

print("history-check: %d historical entries compared against their earliest archive, "
      "across %d archived versions"
      % (checked, len([d for d in os.listdir(arc) if os.path.isdir(os.path.join(arc, d))])))

if not violations:
    print("CLEAN — no historical factual claim has been altered.")
    raise SystemExit(0)

seen = set()
for f, kind, ver, src, was, now in violations:
    key = (f, kind, ver)
    if key in seen:
        continue
    seen.add(key)
    print("\n  ALTERED  %s — %s %s  (archive %s)" % (f, kind, ver, src))
    print("    archive: %s" % was)
    print("    live   : %s" % now)
print("\nSTOP. %d historical entries differ from the archive. "
      "Historical facts are not editable; restore from the archive." % len(seen))
raise SystemExit(1)
PY
