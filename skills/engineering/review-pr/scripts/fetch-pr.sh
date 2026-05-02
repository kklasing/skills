#!/usr/bin/env bash
# Fetch a GitHub PR for review: metadata, commits, files, and diff.
#
# Usage: fetch-pr.sh <pr-number>
#
# Output sections (each prefixed with `===== <NAME> =====`):
#   METADATA  JSON: number, title, body, author, base/head refs, headRefOid (head SHA),
#             state, isDraft, mergeable, additions, deletions, changedFiles, labels,
#             reviewDecision, statusCheckRollup
#   COMMITS   "<short-sha>\t<subject>" per line  (use these for conventional-commit checks)
#   FILES     "<path>\t+<adds>/-<dels>" per line
#   DIFF      full unified diff

set -euo pipefail

if [ "${1:-}" = "" ]; then
  echo "Usage: $(basename "$0") <pr-number>" >&2
  exit 2
fi

PR="$1"

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh (GitHub CLI) is required. Install: https://cli.github.com/" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "ERROR: gh is not authenticated. Run 'gh auth login'." >&2
  exit 1
fi

echo "===== METADATA ====="
gh pr view "$PR" --json number,title,body,author,baseRefName,headRefName,headRefOid,state,isDraft,mergeable,additions,deletions,changedFiles,labels,reviewDecision,statusCheckRollup

echo
echo "===== COMMITS ====="
gh pr view "$PR" --json commits --jq '.commits[] | "\(.oid[0:8])\t\(.messageHeadline)"'

echo
echo "===== FILES ====="
gh pr view "$PR" --json files --jq '.files[] | "\(.path)\t+\(.additions)/-\(.deletions)"'

echo
echo "===== DIFF ====="
gh pr diff "$PR"
