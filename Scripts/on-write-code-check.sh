#!/usr/bin/env bash
# Runs after an agent writes/edits Swift code: lints via SwiftLint, runs the
# affected unit-test scheme, and surfaces CODE_STYLE.md for self-checking.
# Shared entry point for both the Claude Code PostToolUse hook (automatic) and
# Codex, whose AGENTS.md instructs it to call this manually after Swift edits.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

file_path="${1:-}"

if [[ -n "$file_path" && "$file_path" != *.swift ]]; then
  exit 0
fi

run_tests() {
  local schemes=()
  local relative_path="${file_path#$repo_root/}"
  if [[ -n "$file_path" && "$relative_path" =~ ^Modules/([^/]+)/ ]]; then
    local module_name="${BASH_REMATCH[1]}"
    if [[ -d "$repo_root/Modules/$module_name/Tests" ]]; then
      schemes=("${module_name}Tests")
    else
      local destination_id
      destination_id="$(xcrun simctl list devices booted | sed -nE 's/.*\\(([A-F0-9-]{36})\\).*/\\1/p' | head -n 1)"
      if [[ -z "$destination_id" ]]; then
        echo "No booted iOS Simulator found; unable to build $module_name." >&2
        return 1
      fi

      echo "---- Building module without unit tests: $module_name ----"
      xcodebuild \
        -project "$repo_root/Abacaxi.xcodeproj" \
        -scheme "$module_name" \
        -destination "platform=iOS Simulator,id=$destination_id" \
        build
      return
    fi
  else
    while IFS= read -r test_directory; do
      schemes+=("$(basename "$(dirname "$test_directory")")Tests")
    done < <(find "$repo_root/Modules" -mindepth 2 -maxdepth 2 -type d -name Tests | sort)
  fi

  local destination_id
  destination_id="$(xcrun simctl list devices booted | sed -nE 's/.*\\(([A-F0-9-]{36})\\).*/\\1/p' | head -n 1)"

  if [[ -z "$destination_id" ]]; then
    echo "No booted iOS Simulator found; unable to run unit tests." >&2
    return 1
  fi

  local scheme
  for scheme in "${schemes[@]}"; do
    echo "---- Running unit tests: $scheme ----"
    xcodebuild \
      -project "$repo_root/Abacaxi.xcodeproj" \
      -scheme "$scheme" \
      -destination "platform=iOS Simulator,id=$destination_id" \
      test
  done
}

lint_status=0
lint_output="$("$repo_root/Scripts/swiftlint.sh" 2>&1)" || lint_status=$?

echo "$lint_output"

test_status=0
run_tests || test_status=$?

if [[ -s "$repo_root/.claude/CODE_STYLE.md" ]]; then
  echo
  echo "---- CODE_STYLE.md (check the code above against this) ----"
  cat "$repo_root/.claude/CODE_STYLE.md"
fi

if [[ "$lint_status" -ne 0 ]]; then
  exit "$lint_status"
fi

exit "$test_status"
