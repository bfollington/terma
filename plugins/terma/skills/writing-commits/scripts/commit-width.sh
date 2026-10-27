#!/bin/bash
# Check a commit message's width. The subject must be at most 72 characters,
# line 2 must be blank, and body lines must be at most 72 columns. A line that
# holds only a URL may be longer.
#
#   commit-width.sh                # check the message of the HEAD commit
#   commit-width.sh <ref>          # check the message of another commit
#   commit-width.sh -f msg.txt     # check a message file before committing
#   commit-width.sh -              # check a message on stdin
set -euo pipefail

if [ "${1:-}" = "-f" ]; then
  msg=$(cat "$2")
elif [ "${1:-}" = "-" ]; then
  msg=$(cat)
else
  msg=$(git log -1 --format=%B "${1:-HEAD}")
fi

printf '%s\n' "$msg" | awk '
  /^#/ { next }
  { n++ }
  n == 1 {
    if (length($0) > 72) { printf "subject is %d characters (limit 72): %s\n", length($0), $0; bad = 1 }
    next
  }
  n == 2 && $0 != "" { print "line 2 must be blank"; bad = 1 }
  length($0) > 72 && $0 !~ /^[[:space:]]*<?https?:\/\/[^[:space:]]*>?[[:space:]]*$/ {
    printf "line %d is %d columns (limit 72): %s\n", n, length($0), $0; bad = 1
  }
  END { if (bad) exit 1; print "ok: subject and body fit in 72 columns" }
'
