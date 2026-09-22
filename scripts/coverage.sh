#!/usr/bin/env bash
# coverage.sh - compare TOOLS.md and ENTRY.md with what the public repos contain
#
# Usage: scripts/coverage.sh [-h]
#
# Reads the file lists of sysadmin-linux, sysadmin-windows, and homelab-public
# from GitHub and reports three things:
#   1. Scripts in those repos that TOOLS.md does not mention.
#   2. File names that TOOLS.md or ENTRY.md cite that no longer exist in them.
#   3. Runbooks, checklists, or templates TOOLS.md names that ENTRY.md never
#      cites anywhere, so a matching situation would have nothing to route to.
# Docs are otherwise checked only for existence when cited, not for
# completeness: a cheatsheet or reference doc TOOLS.md leaves out is not an
# error the way an unrouted runbook is. It never edits anything. Run it
# during a refresh, after scripts/check.sh.
#
# Options:
#   -h    Show this help and exit.
#
# Exit codes:
#   0  every script is listed and every cited file exists
#   1  one or more findings
#   2  bad usage or a missing tool
#   3  a repo's file list could not be read

usage() { sed -n '2,/^[^#]/p' "$0" | sed '1{/^#$/d;}; $d; s/^# \{0,1\}//'; exit "${1:-0}"; }

while getopts ":h" opt; do
  case "$opt" in
    h) usage 0 ;;
    *) usage 2 ;;
  esac
done

for c in curl python3; do
  command -v "$c" >/dev/null 2>&1 || { echo "coverage.sh: missing required command: $c" >&2; exit 2; }
done

root=$(cd "$(dirname "$0")/.." && pwd) || exit 2
tmp=$(mktemp -d) || exit 2
trap 'rm -rf "$tmp"' EXIT

owner=arlytrenck
for r in sysadmin-linux sysadmin-windows homelab-public; do
  curl -fsS --max-time 30 "https://api.github.com/repos/$owner/$r/git/trees/main?recursive=1" \
    -o "$tmp/$r.json" || { echo "coverage.sh: cannot read the file list of $owner/$r" >&2; exit 3; }
done

python3 - "$root" "$tmp" <<'PY'
import json, os, re, sys

root, tmp = sys.argv[1], sys.argv[2]

def files(repo):
    data = json.load(open(f"{tmp}/{repo}.json"))
    if data.get("truncated"):
        print(f"coverage.sh: the file list of {repo} was truncated by GitHub", file=sys.stderr)
        sys.exit(3)
    return [t["path"] for t in data["tree"] if t["type"] == "blob"]

lin, win, hp = files("sysadmin-linux"), files("sysadmin-windows"), files("homelab-public")

# The scripts each repo ships: scripts/ in the two toolkits, tools/ in homelab-public.
scripts = {}
for repo, paths, prefix, exts in (
    ("sysadmin-linux", lin, "scripts/", (".sh",)),
    ("sysadmin-windows", win, "scripts/", (".ps1",)),
    ("homelab-public", hp, "tools/", (".sh",)),
):
    for p in paths:
        if p.startswith(prefix) and p.endswith(exts):
            scripts[os.path.basename(p)] = repo

existing = {os.path.basename(p) for p in lin + win + hp}
own = {"TOOLS.md", "ENTRY.md", "OPINIONS.md", "VOICE.md", "REFRESH.md", "README.md", "CLAUDE.md", "SKILL.md"}

tools = open(f"{root}/TOOLS.md", encoding="utf-8").read()
entry = open(f"{root}/ENTRY.md", encoding="utf-8").read()

missing = sorted((r, n) for n, r in scripts.items() if n not in tools)
cited = set(re.findall(r"`([A-Za-z0-9._/-]+\.(?:md|sh|ps1))`", tools + "\n" + entry))
dead = sorted(n for n in (os.path.basename(c) for c in cited) if n not in existing and n not in own)

# A "situation doc": a runbook, checklist, or template TOOLS.md names. If
# ENTRY.md never mentions it anywhere, a real situation has nothing to route
# to, which is a routing gap, not just a missing citation.
situation_docs = sorted(set(re.findall(
    r"`([a-z0-9.-]+-(?:runbook|checklist|template)\.md)`", tools)))
unrouted = [d for d in situation_docs if d not in entry]

status = 0
if missing:
    status = 1
    print("Scripts in the public repos that TOOLS.md does not mention:")
    for repo, name in missing:
        print(f"  {repo}: {name}")
if dead:
    status = 1
    if missing:
        print()
    print("File names cited in TOOLS.md or ENTRY.md that do not exist in the public repos:")
    for name in dead:
        print(f"  {name}")
if unrouted:
    status = 1
    if missing or dead:
        print()
    print("Runbooks/checklists/templates TOOLS.md names that ENTRY.md never routes to:")
    for name in unrouted:
        print(f"  {name}")
if status == 0:
    print(f"coverage.sh: clean ({len(scripts)} scripts listed, {len(cited)} cited names exist, "
          f"{len(situation_docs)} situation docs all routed)")
sys.exit(status)
PY
