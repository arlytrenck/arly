#!/usr/bin/env bash
# check.sh - pre-commit guard for the /arly knowledge base
#
# Usage: scripts/check.sh [-h]
#
# Scans the tracked text files in this repo for things that must never be
# committed here: em dashes, names of private repositories, private key
# material, common token prefixes, and private-range IP addresses.
#
# Options:
#   -h    Show this help and exit.
#
# Exit codes:
#   0  clean
#   1  one or more findings
#   2  bad usage

usage() { sed -n '2,/^[^#]/p' "$0" | sed '1{/^#$/d;}; $d; s/^# \{0,1\}//'; exit "${1:-0}"; }

while getopts ":h" opt; do
  case "$opt" in
    h) usage 0 ;;
    *) usage 2 ;;
  esac
done

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root" || exit 2

# This file lists the patterns it searches for, so it must not scan itself.
files=()
while IFS= read -r f; do
  [[ "$f" == "scripts/check.sh" ]] && continue
  files+=("$f")
done < <(find . -type f \( -name '*.md' -o -name '*.sh' -o -name '*.json' -o -name '*.yml' -o -name '*.yaml' \) \
  -not -path './.git/*' -not -path './.sources/*' | sed 's|^\./||' | sort)

status=0

scan() {
  local label=$1 pattern=$2 hits
  hits=$(grep -nE "$pattern" "${files[@]}" 2>/dev/null)
  if [[ -n "$hits" ]]; then
    printf 'FAIL: %s\n%s\n\n' "$label" "$hits"
    status=1
  fi
}

# U+2014, matched as bytes so it works regardless of locale
scan "em dash" $'\xe2\x80\x94'
scan "private repository name" 'homelab-private|homelab-infra|wp-it|at-srv|Sotheby'
scan "private key material" 'BEGIN [A-Z ]*PRIVATE KEY'
scan "token prefix" '(ghp_|gho_|github_pat_|xox[baprs]-|AKIA)[A-Za-z0-9_]{8,}'
scan "private-range IP address" '(^|[^0-9.])(10\.[0-9]{1,3}|192\.168|172\.(1[6-9]|2[0-9]|3[01]))\.[0-9]{1,3}\.[0-9]{1,3}([^0-9]|$)'

if [[ $status -eq 0 ]]; then
  echo "check.sh: clean (${#files[@]} files scanned)"
fi
exit $status
