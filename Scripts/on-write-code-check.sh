#!/usr/bin/env bash
# Runs after an agent writes/edits Swift code: lints via SwiftLint, runs the
# affected unit-test scheme, and surfaces contextual code rules for self-checking.
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
      destination_id="$(xcrun simctl list devices booted | sed -nE 's/.*\(([A-F0-9-]{36})\).*/\1/p' | head -n 1)"
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
  elif [[ -n "$file_path" ]]; then
    # App-shell files: the full AllTests suite exceeds the hook timeout.
    # Run it via `make test` or rely on CI; the hook covers lint + rules.
    echo "File outside Modules/: skipping test run (use 'make test' or CI for the AllTests suite)."
    return 0
  else
    schemes=("AllTests")
  fi

  local destination_id
  destination_id="$(xcrun simctl list devices booted | sed -nE 's/.*\(([A-F0-9-]{36})\).*/\1/p' | head -n 1)"

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

print_code_rules() {
  local rule_files=("00-overview.md")
  local relative_path="${file_path#$repo_root/}"

  if [[ -z "$file_path" ]]; then
    rule_files+=(
      "10-testing.md"
      "20-swift.md"
      "30-architecture.md"
      "40-uikit.md"
      "50-validation.md"
    )
  elif [[ "$relative_path" == */Tests/* ]]; then
    rule_files+=("10-testing.md" "20-swift.md" "50-validation.md")
  else
    rule_files+=("20-swift.md" "30-architecture.md")

    if [[ "$file_path" == *View.swift || "$file_path" == *ViewController.swift ]] || \
      grep -qE '^import (UIKit|SwiftUI)$' "$file_path"; then
      rule_files+=("40-uikit.md")
    fi

    rule_files+=("50-validation.md")
  fi

  local rule_file
  for rule_file in "${rule_files[@]}"; do
    echo
    echo "---- CODE_RULES/$rule_file ----"
    cat "$repo_root/.claude/CODE_RULES/$rule_file"
  done
}

lint_status=0
lint_output="$("$repo_root/Scripts/swiftlint.sh" 2>&1)" || lint_status=$?

echo "$lint_output"

test_status=0
run_tests || test_status=$?

print_code_rules

if [[ "$lint_status" -ne 0 ]]; then
  exit "$lint_status"
fi

exit "$test_status"
