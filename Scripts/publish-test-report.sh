#!/usr/bin/env bash
# Publishes the aggregated test report (Scripts/test-report.sh) to the
# GitHub Actions job summary and as a sticky PR comment (created once,
# updated on every subsequent run — identified by the marker below).
# Never fails: reporting must not mask the Test step's real status.
#
# Expects (in CI): GH_TOKEN, PR_NUMBER, GITHUB_REPOSITORY.
# Usage: Scripts/publish-test-report.sh [<results-dir>]
set -uo pipefail

marker="<!-- abacaxi-test-report -->"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

report="$(bash "$script_dir/test-report.sh" "${1:-build/test-results}")"

printf '%s\n' "$report"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  printf '%s\n' "$report" >> "$GITHUB_STEP_SUMMARY"
fi

if [[ -z "${PR_NUMBER:-}" || -z "${GH_TOKEN:-}" || -z "${GITHUB_REPOSITORY:-}" ]]; then
  echo "(sem PR/token — relatório não publicado como comentário)"
  exit 0
fi

body="$marker
$report"

existing="$(gh api "repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments" \
  --jq ".[] | select(.body | startswith(\"$marker\")) | .id" 2>/dev/null | head -n 1 || true)"

if [[ -n "$existing" ]]; then
  gh api -X PATCH "repos/$GITHUB_REPOSITORY/issues/comments/$existing" \
    -f body="$body" >/dev/null && echo "Comentário de relatório atualizado (id $existing)."
else
  gh pr comment "$PR_NUMBER" --repo "$GITHUB_REPOSITORY" --body "$body" \
    && echo "Comentário de relatório criado no PR #$PR_NUMBER."
fi

exit 0
