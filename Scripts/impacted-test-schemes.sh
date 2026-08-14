#!/usr/bin/env bash
# Prints the test schemes impacted by the changes between two refs:
# the schemes of every changed module plus all transitive dependents,
# derived from the local package graph in Modules/*/Package.swift.
# Falls back to the full AllTests scheme whenever the blast radius is
# not provable from the graph (changes outside Modules/, manifest or
# project changes), so selection can only ever run MORE than needed.
#
# Usage: Scripts/impacted-test-schemes.sh [<base-ref>] [<head-ref>]
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

base_ref="${1:-origin/main}"
head_ref="${2:-HEAD}"

changed_files="$(git diff --name-only "$base_ref"..."$head_ref")"

if [[ -z "$changed_files" ]]; then
  echo "AllTests"
  exit 0
fi

# Anything we cannot attribute to a single module invalidates selection:
# app-shell sources, build/tooling files, and manifests (they change the
# graph this script relies on).
while IFS= read -r file; do
  if [[ "$file" != Modules/*/* || "$file" == */Package.swift ]]; then
    echo "AllTests"
    exit 0
  fi
done <<< "$changed_files"

changed_modules="$(echo "$changed_files" | sed -nE 's|^Modules/([^/]+)/.*|\1|p' | sort -u)"

# Reverse dependency edges as "dependency dependent" lines (bash 3.2
# on macOS has no associative arrays).
edges=""
for manifest in Modules/*/Package.swift; do
  module="$(basename "$(dirname "$manifest")")"
  deps="$(grep -oE '\.package\(path: "\.\./[A-Za-z]+"\)' "$manifest" | sed -E 's|.*\.\./([A-Za-z]+).*|\1|' || true)"
  for dep in $deps; do
    edges="${edges}${dep} ${module}
"
  done
done

dependents_of() {
  echo "$edges" | awk -v dep="$1" '$1 == dep { print $2 }'
}

# Breadth-first closure over dependents.
impacted=""
queue="$changed_modules"
while [[ -n "${queue// /}" ]]; do
  next=""
  for module in $queue; do
    if [[ " $impacted " != *" $module "* ]]; then
      impacted="$impacted $module"
      next="$next $(dependents_of "$module")"
    fi
  done
  queue="$next"
done

schemes=""
for module in $(echo "$impacted" | tr ' ' '\n' | sort -u); do
  [[ -z "$module" ]] && continue
  if [[ -d "Modules/$module/Tests" ]]; then
    schemes="$schemes ${module}Tests"
  fi
done

schemes="$(echo "$schemes" | xargs)"
if [[ -z "$schemes" ]]; then
  echo "AllTests"
else
  echo "$schemes"
fi
