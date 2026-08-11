#!/usr/bin/env bash
# Runs after an agent writes/edits Swift code: lints via SwiftLint and surfaces
# CODE_STYLE.md so the agent can self-check style conformance on top of it.
# Shared entry point for both the Claude Code PostToolUse hook (automatic) and
# Codex, whose AGENTS.md instructs it to call this manually after Swift edits.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

file_path="${1:-}"

if [[ -n "$file_path" && "$file_path" != *.swift ]]; then
  exit 0
fi

lint_status=0
lint_output="$("$repo_root/Scripts/swiftlint.sh" 2>&1)" || lint_status=$?

echo "$lint_output"

if [[ -s "$repo_root/.claude/CODE_STYLE.md" ]]; then
  echo
  echo "---- CODE_STYLE.md (check the code above against this) ----"
  cat "$repo_root/.claude/CODE_STYLE.md"
fi

exit "$lint_status"
