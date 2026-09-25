#!/usr/bin/env bash
# FOLDER-LEDGER generator — Triade design set
#
# Contract: TRIADE-Design_Stream_Project_Instructions, Session protocol / The ledger.
#   Records every file under the documentation root, sorted by path.
#   Fields: path (relative, forward slashes), bytes, sha256, mtime_utc (ISO-8601 Z).
#   Excludes FOLDER-LEDGER.json, the untracked Research/ tree, and __pycache__.
#   Recursive otherwise.
#   Research/ holds imported third-party material and retired reconciliation records;
#   it carries no design authority, so churn there is noise, not signal.
#
# Usage:
#   ledger.sh write [root]    regenerate and overwrite FOLDER-LEDGER.json
#   ledger.sh check [root]    regenerate in memory, diff against the stored ledger
#
# Exit codes:
#   0  clean (check) / written (write)
#   1  content differences found — added, removed or modified
#   2  no stored ledger: unknown state, not clean state
#   3  usage or root error
#
# Diff tiers: a hash or size change is BLOCKING. An mtime-only change is
# INFORMATIONAL — a sync or a file-copy tool can restamp mtime without touching
# a byte, and a blocking stop on that would train the stop to be ignored.

set -euo pipefail

MODE="${1:-}"
DEFAULT_ROOT="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
ROOT="${2:-$DEFAULT_ROOT}"

case "$MODE" in
  write|check) ;;
  *) echo "usage: $(basename "$0") write|check [root]" >&2; exit 3 ;;
esac
[ -d "$ROOT" ] || { echo "ledger: not a directory: $ROOT" >&2; exit 3; }

python3 - "$MODE" "$ROOT" <<'PY'
import datetime, hashlib, json, os, sys

mode, root = sys.argv[1], os.path.realpath(sys.argv[2])
LEDGER_NAME = "FOLDER-LEDGER.json"
LEDGER_PATH = os.path.join(root, LEDGER_NAME)
EXCLUDE = {LEDGER_NAME}
EXCLUDE_DIRS = {"Research", ".git", "__pycache__"}   # Research: untracked; .git: operational metadata; __pycache__: build artefact


def now_z():
    return (datetime.datetime.now(datetime.timezone.utc)
            .replace(microsecond=0).isoformat().replace("+00:00", "Z"))


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def scan():
    entries = []
    for dirpath, dirnames, filenames in os.walk(root):
        if dirpath == root:
            dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        dirnames.sort()
        for name in sorted(filenames):
            full = os.path.join(dirpath, name)
            if not os.path.isfile(full):
                continue
            rel = os.path.relpath(full, root).replace(os.sep, "/")
            if rel in EXCLUDE:
                continue
            st = os.stat(full)
            entries.append({
                "path": rel,
                "bytes": st.st_size,
                "sha256": sha256(full),
                "mtime_utc": (datetime.datetime
                              .fromtimestamp(st.st_mtime, datetime.timezone.utc)
                              .replace(microsecond=0).isoformat()
                              .replace("+00:00", "Z")),
            })
    entries.sort(key=lambda e: e["path"])
    return {
        "schema": "triade-folder-ledger/1",
        "generated_utc": now_z(),
        "root": os.path.basename(root),
        "file_count": len(entries),
        "total_bytes": sum(e["bytes"] for e in entries),
        "files": entries,
    }


fresh = scan()

if mode == "write":
    with open(LEDGER_PATH, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(fresh, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    print("ledger written: %d files, %d bytes, %s"
          % (fresh["file_count"], fresh["total_bytes"], fresh["generated_utc"]))
    raise SystemExit(0)

if not os.path.exists(LEDGER_PATH):
    print("LEDGER ABSENT — unknown state, not clean state.")
    print("Spot-check two files by hand, then run: ledger.sh write")
    raise SystemExit(2)

with open(LEDGER_PATH, encoding="utf-8") as fh:
    stored = json.load(fh)

old = {e["path"]: e for e in stored.get("files", [])}
new = {e["path"]: e for e in fresh["files"]}

added = sorted(new.keys() - old.keys())
removed = sorted(old.keys() - new.keys())
modified, touched = [], []
for path in sorted(new.keys() & old.keys()):
    if new[path]["sha256"] != old[path]["sha256"]:
        modified.append(path)
    elif new[path]["mtime_utc"] != old[path]["mtime_utc"]:
        touched.append(path)

print("ledger stored  : %s (%d files)"
      % (stored.get("generated_utc", "?"), stored.get("file_count", -1)))
print("ledger now     : %s (%d files)"
      % (fresh["generated_utc"], fresh["file_count"]))

for label, items in (("ADDED", added), ("REMOVED", removed), ("MODIFIED", modified)):
    for path in items:
        print("  %-9s %s" % (label, path))
for path in touched:
    print("  %-9s %s (content identical)" % ("touched", path))

if added or removed or modified:
    print("\nSTOP. %d blocking change(s) made outside a session. "
          "Report the list; do not patch until reconciled."
          % (len(added) + len(removed) + len(modified)))
    raise SystemExit(1)

print("\nCLEAN — folder is as the last session left it."
      + (" %d mtime-only change(s), informational." % len(touched) if touched else ""))
raise SystemExit(0)
PY
