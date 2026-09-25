#!/usr/bin/env bash
# Sweep-for-the-removed.
#
# The dominant failure class in this corpus is retiring a term and leaving its
# consumers: `base_AP_pool` survived two releases past the pool; W·907 was
# rewritten to world_tick pulses with the old clause left in the same sentence;
# K·132 kept a locked constraint on an abolished resource. Every verification
# grep searched for the text that had been ADDED.
#
# This searches for what was REMOVED. Every surviving occurrence of a retired
# token must be a negation, a changelog row, or an explicitly historical
# statement — enumerated, never eyeballed.
#
# Registry: tools/retired-terms.tsv  (token <TAB> retired_at <TAB> note)
#
#   exit 0  every survivor accounted for      exit 1  a live use      exit 3  usage
set -euo pipefail
ROOT="${1:-$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)}"
[ -d "$ROOT" ] || { echo "retirement-check: not a directory: $ROOT" >&2; exit 3; }
python3 - "$ROOT" <<'PY'
import glob, os, re, sys
root = sys.argv[1]
reg = os.path.join(root, "tools", "retired-terms.tsv")
if not os.path.exists(reg):
    print("retirement-check: no registry at tools/retired-terms.tsv"); raise SystemExit(3)

# A survivor is accounted for when the line marks it as gone or records history.
NEG = re.compile(r'retired|retire[sd]?\b|no longer|never|not\b|struck|removed|formerly|was\b|until \d|superseded|abolished|replaced|prohibit|forbid|barred|invalid|~~|deprecat', re.I)
CHANGELOG = re.compile(r'^\|\s*\*\*\d+\.\d+\.\d+\*\*\s*\|')
RELEASE_HEADING = re.compile(r'^#{1,3}\s+\d+\.\d+\.\d+\s+release summary', re.I)
HIST = re.compile(r'\[(?:LOCKED|AUTHORED|ADOPTED|CLOSED|CORRECTED|RECONCILED|RESTATED)\s+\d+\.\d+\.\d+', re.I)

terms = []
for line in open(reg, encoding="utf-8"):
    if line.startswith("#") or not line.strip(): continue
    parts = line.rstrip("\n").split("\t")
    terms.append((parts[0], parts[1] if len(parts) > 1 else "?"))

live = []; checked = 0
for f in sorted(glob.glob(os.path.join(root, "*.md"))):
    name = os.path.basename(f)
    if name.startswith(("00-", "01-", "02-")) or name.startswith("Z-Design"):
        continue                                    # process records name retired tokens as examples
    if False:
        continue
    in_history = False
    for n, l in enumerate(open(f, encoding="utf-8"), 1):
        # Everything at or below a "## <version> release summary" heading is
        # history: P-C11 forbids sweeping it, so a survivor there is not live.
        if RELEASE_HEADING.match(l):
            in_history = True
        for tok, ver in terms:
            if tok in l:
                checked += 1
                if in_history or CHANGELOG.match(l.strip()) or NEG.search(l) or HIST.search(l):
                    continue
                live.append((name, n, tok, ver, l.strip()[:70]))
print("retirement-check: %d registered token(s), %d occurrence(s) examined"
      % (len(terms), checked))
for name, n, tok, ver, ctx in live:
    print("  LIVE USE  %-44s :%-5d `%s` (retired %s)" % (name[:44], n, tok, ver))
    print("            %s" % ctx)
if live:
    print("\nSTOP. %d surviving use(s) of a retired token are neither negation, "
          "changelog nor dated history." % len(live))
    raise SystemExit(1)
print("CLEAN — every survivor is a negation, a changelog row or dated history.")
PY
