#!/usr/bin/env python3
"""
One-way mirror: X:\\Documentation  ->  a Google Drive folder.

X:\\Documentation is authoritative. Drive is a controlled copy: every change is
an upload, an in-place update, or a move to Trash. No archive is kept on Drive —
the archive lives under X:\\Documentation-Archive\\Archive and is never synced.

WHY THIS IS A SCRIPT AND NOT AN MCP CALL
  The Drive MCP connector can create and read but cannot update or delete, so a
  write with an existing title produces a duplicate. A service account with the
  full drive scope can update and trash, which is what a mirror needs.

WHERE TO RUN IT
  On your machine, not in the Claude sandbox: the sandbox proxy refuses
  *.googleapis.com with HTTP 403, so the token exchange cannot complete there.

    pip install google-api-python-client google-auth
    python drive-sync.py --key ..\\..\\secrets\\service_account.json \\
                         --folder 1HoIPDFFyxD2_XnfrRDPQ69SYUB3eUGde
    python drive-sync.py --key ... --folder ... --apply

  Without --apply it only reports. Nothing is written.

WHAT IT SYNCS
  Exactly the tracked set, read from FOLDER-LEDGER.json — so Research\\ is
  excluded by the same decision that excludes it from the ledger. Files are
  compared by size and MD5.

  new on disk        -> uploaded
  changed            -> updated in place, same file ID, revision history kept
  absent from disk   -> moved to Trash (recoverable for 30 days)

SECURITY
  Never place the key inside X:\\Documentation. The ledger would hash it and the
  next bump would copy it into a write-once archive snapshot that is never
  edited. This script refuses to run if the key sits under the documentation
  root. Rotate any key that has been pasted into a chat.
"""
import argparse, hashlib, json, os, sys

SCOPES = ["https://www.googleapis.com/auth/drive"]   # NOT 'https://googleapis.com' — that is not a scope


def md5(path):
    h = hashlib.md5()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def tracked(root):
    """The tracked set, exactly as the ledger defines it."""
    led = os.path.join(root, "FOLDER-LEDGER.json")
    if not os.path.exists(led):
        sys.exit("drive-sync: no FOLDER-LEDGER.json — run tools/ledger.sh write first")
    files = {e["path"]: os.path.join(root, e["path"])
             for e in json.load(open(led, encoding="utf-8"))["files"]}
    files["FOLDER-LEDGER.json"] = led          # the ledger excludes itself; the mirror should not
    return files


def build_service(key):
    from google.oauth2 import service_account
    from googleapiclient.discovery import build
    creds = service_account.Credentials.from_service_account_file(key, scopes=SCOPES)
    return build("drive", "v3", credentials=creds, cache_discovery=False)


FOLDER_MIME = "application/vnd.google-apps.folder"


def _children(svc, parent):
    out, token = [], None
    while True:
        r = svc.files().list(q="'%s' in parents and trashed=false" % parent,
                             fields="nextPageToken, files(id,name,size,md5Checksum,mimeType)",
                             pageSize=1000, pageToken=token).execute()
        out += r.get("files", [])
        token = r.get("nextPageToken")
        if not token:
            return out


def remote_index(svc, folder):
    """Map Drive contents by RELATIVE PATH, walking subfolders.

    Subdirectories are mirrored, not flattened. A first version keyed on
    basename alone, which would have put tools/ledger.sh at the Drive root and
    collided the moment two subdirectories shared a filename.
    """
    out, dirs = {}, {"": folder}

    def walk(parent, prefix):
        for f in _children(svc, parent):
            rel = (prefix + "/" + f["name"]).lstrip("/")
            if f["mimeType"] == FOLDER_MIME:
                dirs[rel] = f["id"]
                walk(f["id"], rel)
            else:
                out.setdefault(rel, []).append(f)

    walk(folder, "")
    return out, dirs


def duplicate_dirs(svc, folder):
    """Folders sharing a name under the same parent.

    The first --apply run created a `tools` folder as the SERVICE ACCOUNT
    (folders cost no storage, so that call succeeded) and then failed to create
    the files inside it on quota. That left an empty orphan owned by the service
    account, invisible to the file-level diff because remote_index walks folders
    rather than listing them. Reported, never trashed: an empty folder is
    harmless, and a non-empty one deleted by a script is not.
    """
    seen, dupes = {}, []
    for f in _children(svc, folder):
        if f["mimeType"] != FOLDER_MIME:
            continue
        if f["name"] in seen:
            dupes.append(f["name"])
        seen[f["name"]] = f["id"]
    return sorted(set(dupes))


def ensure_dir(svc, dirs, rel, root, apply_):
    """Return the Drive folder id for a relative directory, creating it if needed."""
    if rel in dirs:
        return dirs[rel]
    parent = ensure_dir(svc, dirs, os.path.dirname(rel), root, apply_) if os.path.dirname(rel) else root
    if not apply_:
        return None
    f = svc.files().create(body={"name": os.path.basename(rel), "parents": [parent],
                                 "mimeType": FOLDER_MIME}, fields="id").execute()
    dirs[rel] = f["id"]
    return f["id"]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--key", required=True)
    ap.add_argument("--folder", required=True)
    ap.add_argument("--root", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    ap.add_argument("--apply", action="store_true", help="perform the writes; otherwise report only")
    a = ap.parse_args()

    root = os.path.realpath(a.root)
    key = os.path.realpath(a.key)
    if key.startswith(root + os.sep):
        sys.exit("drive-sync: REFUSING — the key is inside the documentation root.\n"
                 "  The ledger would hash it and the next bump would archive it permanently.")

    local = tracked(root)
    svc = build_service(key)
    remote, dirs = remote_index(svc, a.folder)

    dd = duplicate_dirs(svc, a.folder)
    if dd:
        print("  WARNING — duplicate folder names on Drive: %s" % ", ".join(dd))
        print("  Likely an empty folder created by the service account during a run whose")
        print("  file creates then failed on storage quota. Delete the empty one by hand;")
        print("  this script will not trash a folder.\n")

    if not remote:
        print("  WARNING — Drive folder reads as EMPTY.")
        print("  Drive returns nothing rather than an error when a service account")
        print("  cannot see a folder. Check the folder is shared with:")
        print("      %s" % json.load(open(key, encoding="utf-8")).get("client_email"))
        print("  as Editor. Do NOT --apply against an empty read: every file would")
        print("  upload as a duplicate of one already there.\n")

    from googleapiclient.http import MediaFileUpload
    upload, update, trash, same, dupes = [], [], [], [], []

    for rel, path in sorted(local.items()):
        rel = rel.replace(os.sep, "/")
        matches = remote.get(rel, [])
        if len(matches) > 1:
            dupes.append(rel)
        if not matches:
            upload.append((rel, path))
        else:
            r = matches[0]
            if r.get("md5Checksum") != md5(path):
                update.append((rel, path, r["id"]))
            else:
                same.append(rel)

    keep = {r.replace(os.sep, "/") for r in local}
    for rel, entries in remote.items():
        for e in entries:
            if rel not in keep:
                trash.append((rel, e["id"]))

    print("mirror  %s  ->  Drive folder %s" % (root, a.folder))
    print("  unchanged %d | upload %d | update %d | trash %d"
          % (len(same), len(upload), len(update), len(trash)))
    for n, _ in upload:      print("    UPLOAD  %s" % n)
    for n, _, _ in update:   print("    UPDATE  %s" % n)
    for n, _ in trash:       print("    TRASH   %s" % n)
    if dupes:
        print("\n  DUPLICATE TITLES ON DRIVE — the connector's create-only writes made these;")
        print("  the mirror updates the first and cannot tell which a reader opened:")
        for n in sorted(set(dupes)):
            print("    %s" % n)

    if not a.apply:
        print("\n  dry run. Nothing written. Re-run with --apply.")
        return

    # ORDER MATTERS. Updates and trashes act on files the user owns and always
    # work. Creates make a file the SERVICE ACCOUNT would own, and a service
    # account has no storage quota on a consumer account — Google returns
    # storageQuotaExceeded. Shared drives and OAuth delegation both need
    # Workspace. So: do the work that succeeds first, and never let a create
    # failure discard it.
    for name, path, fid in update:
        svc.files().update(fileId=fid, media_body=MediaFileUpload(path, resumable=False),
                           fields="id").execute()
        print("    updated  %s" % name)
    for name, fid in trash:
        svc.files().update(fileId=fid, body={"trashed": True}, fields="id").execute()
        print("    trashed  %s" % name)

    blocked = []
    for name, path in upload:
        sub = os.path.dirname(name)
        try:
            parent = ensure_dir(svc, dirs, sub, a.folder, True) if sub else a.folder
            svc.files().create(body={"name": os.path.basename(name), "parents": [parent]},
                               media_body=MediaFileUpload(path, resumable=False),
                               fields="id").execute()
            print("    uploaded %s" % name)
        except Exception as e:
            if "storageQuotaExceeded" in str(e) or "storage quota" in str(e):
                blocked.append(name)
            else:
                raise

    if blocked:
        print("\n  %d file(s) could not be created by the service account:" % len(blocked))
        for n in blocked:
            print("      %s" % n)
        print("  A service account owns what it creates and has no storage quota on a")
        print("  consumer account. Updates and trashes above still succeeded — those act")
        print("  on files you own. Create these once by any means that makes YOU the")
        print("  owner (the Drive UI, or Claude's Drive connector); from then on this")
        print("  script maintains them in place.")

    print("\n  done.")


if __name__ == "__main__":
    main()
