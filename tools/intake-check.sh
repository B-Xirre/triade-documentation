#!/usr/bin/env bash
# Completion manifests — a claim turned into a checkable list.
#
# "Set 1 adopted in full" and "Set 2 complete" were both false, and both were
# reported with every check green. They were completion claims made for the
# sections written rather than for the work asked. A completion claim that is
# prose cannot be verified; a checklist can.
#
# Every tracked intake record (00-*) must carry a Deliverables checklist. An
# item is DONE only as `- [x] <name> — <document> · <section>`: the section
# reference is what makes the claim checkable by grep rather than by memory.
#
#   exit 0  every record complete or honestly open      exit 1  a claim without a list, or a tick without a home
set -euo pipefail
ROOT="${1:-$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)}"
[ -d "$ROOT" ] || { echo "intake-check: not a directory: $ROOT" >&2; exit 3; }
python3 - "$ROOT" <<'PY'
import glob, os, re, sys
root = sys.argv[1]
recs = sorted(glob.glob(os.path.join(root, "00-*.md")))
bad = 0; total_done = total_open = 0
for f in recs:
    name = os.path.basename(f)
    txt = open(f, encoding="utf-8").read()
    items = re.findall(r'(?m)^\s*- \[([ xX])\]\s*(.+)$', txt)
    claims = re.search(r'\b(complete|in full|fully adopted|all items)\b', txt, re.I)
    if not items:
        if claims:
            print("  NO LIST   %-46s claims completion with no Deliverables checklist" % name[:46]); bad += 1
        else:
            print("  no list   %-46s (no completion claimed — informational)" % name[:46])
        continue
    done = [t for m, t in items if m in "xX"]; open_ = [t for m, t in items if m == " "]
    total_done += len(done); total_open += len(open_)
    unref = [t for t in done if not re.search(r'—.*·|·\s*\S+\s*·|\b§|\bPart\b|\b\d+\.\d+', t)]
    for t in unref:
        print("  NO HOME   %-46s ticked without a document and section: %s" % (name[:46], t[:44])); bad += 1
    print("  %-48s %d done, %d open" % (name[:48], len(done), len(open_)))
print("intake-check: %d record(s), %d delivered, %d open" % (len(recs), total_done, total_open))
if bad:
    print("\nSTOP. %d completion defect(s). A tick without a document and section is an assertion, not a delivery." % bad)
    raise SystemExit(1)
print("CLEAN — every completion claim is backed by a checklist with homes.")
PY
