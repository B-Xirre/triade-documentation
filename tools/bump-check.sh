#!/usr/bin/env bash
# Bump-class assertion, computed from the diff.
#
# 0.35.1 was released as a patch while it added sections and a rule. The standing
# rule is explicit — a patch changes no rule, no number and no section — but it
# was applied by judgement, and judgement at the end of a long session is the
# thing that fails. This computes the class instead.
#
#   bump-check.sh <archived-version-dir>
#   exit 0  digit matches the diff      exit 1  patch digit on a minor change      exit 3  usage
set -euo pipefail
ROOT="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
PREV="${1:-}"
[ -d "$PREV" ] || { echo "usage: bump-check.sh <path-to-previous-archive-dir>" >&2; exit 3; }
python3 - "$ROOT" "$PREV" <<'PY'
import glob, os, re, sys
root, prev = sys.argv[1], sys.argv[2]
VER = re.compile(r'-\d+_\d+_\d+(?=\.md$)')
def stem(p): return VER.sub("", os.path.basename(p))
cur_ver = None
m = re.search(r'(?m)^\*\*Current version:\*\* (\d+)\.(\d+)\.(\d+)', open(os.path.join(root, "VERSION-MANIFEST.md"), encoding="utf-8").read())
if not m: print("bump-check: no current version in manifest"); raise SystemExit(3)
cur = tuple(int(x) for x in m.groups())
old = {stem(p): p for p in glob.glob(os.path.join(prev, "*.md"))}
new_rules = new_heads = 0
RULE = re.compile(r'^\| \*\*(?:TILE|[A-Z])[A-Z]*-[CHM]\d+\*\*')
HEAD = re.compile(r'^#{2,4} ')
for f in sorted(glob.glob(os.path.join(root, "*.md"))):
    o = old.get(stem(f))
    if not o:
        new_heads += 1; continue
    a = set(l for l in open(o, encoding="utf-8") if RULE.match(l.strip()) or HEAD.match(l))
    b = set(l for l in open(f, encoding="utf-8") if RULE.match(l.strip()) or HEAD.match(l))
    for l in b - a:
        if RULE.match(l.strip()): new_rules += 1
        else: new_heads += 1
print("bump-check: %d new rule row(s), %d new heading(s) since %s"
      % (new_rules, new_heads, os.path.basename(prev)))
minor = new_rules > 0 or new_heads > 0
if minor and cur[2] != 0:
    print("\nSTOP. Version %d.%d.%d is a patch digit, but the diff adds %d rule(s) and %d "
          "section(s). A patch changes no rule, no number and no section."
          % (cur[0], cur[1], cur[2], new_rules, new_heads))
    raise SystemExit(1)
print("CLEAN — %s is consistent with the diff." % ("minor" if minor else "patch"))
PY
