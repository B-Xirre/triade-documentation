#!/usr/bin/env bash
# Validation-suite integrity — the two-axis check.
#
# A rule's severity is stated twice: by the letter in its ID (the convention —
# {DOC}-{C|H|M}{n}) and by the section it is filed under. A recount that measures
# one axis is not a recount. At 0.35.0 seven rules were filed under Critical while
# their IDs said High; the totals matched, so every published split was wrong and
# nothing noticed.
#
# Extended 0.36.0: also validates ID uniqueness, the printed severity totals and
# the by-document breakdown. R printed 78/47/14 and a breakdown summing to 180
# while holding 181 rules — the numbers a reader trusts were never checked.
#
#   exit 0  agree      exit 1  disagreement      exit 3  usage
set -euo pipefail
ROOT="${1:-$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)}"
[ -d "$ROOT" ] || { echo "suite-check: not a directory: $ROOT" >&2; exit 3; }
python3 - "$ROOT" <<'PY'
import glob, os, re, sys, collections
root = sys.argv[1]
idx = glob.glob(os.path.join(root, "R-Validation_Rules_Index_*.md"))
if not idx:
    print("suite-check: no rules index found"); raise SystemExit(3)
sec = None; bad = []
by_id = collections.Counter(); by_sec = collections.Counter()
for line in open(idx[0], encoding="utf-8"):
    m = re.match(r'^#{2,4} .*\b(Critical|High|Medium)\b', line, re.I)
    if m: sec = m.group(1).capitalize()
    r = re.match(r'^\| \*\*((?:TILE|[TKMHEWVLPGC])-([CHM])\d+)\*\*', line)
    if r:
        want = {'C': 'Critical', 'H': 'High', 'M': 'Medium'}[r.group(2)]
        by_id[want] += 1
        if sec:
            by_sec[sec] += 1
            if sec != want: bad.append((r.group(1), want, sec))
tot = sum(by_id.values())
print("suite-check: %d rules — by ID %d/%d/%d, by section %d/%d/%d"
      % (tot, by_id['Critical'], by_id['High'], by_id['Medium'],
         by_sec['Critical'], by_sec['High'], by_sec['Medium']))

txt = open(idx[0], encoding="utf-8").read()
ids = re.findall(r'(?m)^\| \*\*((?:TILE|[TKMHEWVLPGC])-[CHM]\d+)\*\*', txt)
dup = [i for i, n in collections.Counter(ids).items() if n > 1]
for d in sorted(dup):
    print("  DUPLICATE %s appears %d times" % (d, ids.count(d))); bad.append((d, "unique", "duplicated"))

def printed(label):
    m = re.search(r'(?m)^\| \*\*%s\*\* \| (\d+) \|' % label, txt)
    return int(m.group(1)) if m else None
for label, key in (("Critical", "Critical"), ("High", "High"), ("Medium", "Medium")):
    p_ = printed(label)
    if p_ is not None and p_ != by_id[key]:
        print("  PRINTED   %s total says %d, measured %d" % (label, p_, by_id[key]))
        bad.append((label, str(by_id[key]), str(p_)))
m = re.search(r'(?m)^\| \*\*Total\*\* \| \*\*(\d+)\*\* \|', txt)
if m and int(m.group(1)) != tot:
    print("  PRINTED   Total says %s, measured %d" % (m.group(1), tot)); bad.append(("Total", str(tot), m.group(1)))
m = re.search(r'(?m)^By document: (.+)$', txt)
if m:
    per = dict((d, int(n)) for d, n in re.findall(r'([A-Z]+) (\d+)', m.group(1)))
    if sum(per.values()) != tot:
        print("  BY-DOC    breakdown sums to %d, measured %d" % (sum(per.values()), tot))
        bad.append(("by-document", str(tot), str(sum(per.values()))))
    actual = collections.Counter("G" if i.split("-")[0] == "TILE" else i.split("-")[0] for i in ids)
    for d in sorted(set(per) | set(actual)):
        if per.get(d, 0) != actual.get(d, 0):
            print("  BY-DOC    %s says %d, measured %d" % (d, per.get(d, 0), actual.get(d, 0)))
            bad.append((d, str(actual.get(d, 0)), str(per.get(d, 0))))
for rid, want, got in bad:
    print("  MISFILED  %-10s ID says %-8s filed under %s" % (rid, want, got))
if bad:
    print("\nSTOP. %d integrity failure(s) — the letter IS the severity, and a printed total is a claim." % len(bad))
    raise SystemExit(1)
print("CLEAN — axes, uniqueness, printed totals and by-document all agree.")
PY
