#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if ! command -v swiftlint >/dev/null 2>&1; then
  echo "error: swiftlint not found. Install with: brew install swiftlint" >&2
  exit 1
fi

strict=false
if [[ "${1:-}" == "--strict" ]]; then
  strict=true
fi

failed_modules=()

lint_target() {
  local name="$1"
  shift
  local existing_paths=()
  for path in "$@"; do
    [[ -d "$path" ]] && existing_paths+=("$path")
  done
  if [[ ${#existing_paths[@]} -eq 0 ]]; then
    return
  fi

  echo "==> ${name}"
  local args=(lint --quiet --config "$repo_root/.swiftlint.yml")
  [[ "$strict" == true ]] && args+=(--strict)
  args+=("${existing_paths[@]}")

  if swiftlint "${args[@]}"; then
    echo "    ok"
  else
    failed_modules+=("$name")
  fi
}

for manifest in Modules/*/Package.swift; do
  module_dir="$(dirname "$manifest")"
  module_name="$(basename "$module_dir")"
  lint_target "$module_name" "$module_dir/Sources" "$module_dir/Tests"
done

lint_target "Abacaxi" "Abacaxi/Sources"

echo
if [[ ${#failed_modules[@]} -gt 0 ]]; then
  echo "SwiftLint failed for: ${failed_modules[*]}"
  exit 1
fi

echo "SwiftLint passed for all modules."
