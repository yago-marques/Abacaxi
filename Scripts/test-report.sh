#!/usr/bin/env bash
# Aggregates test results written by `make test-impacted` (or `make test`
# with TEST_RESULT_BUNDLE) into a markdown report: .xcresult bundles from
# xcodebuild and JUnit XML files from `swift test --xunit-output`.
# Prints the report to stdout; never fails the pipeline (reporting must
# not mask the real test exit status, which already gated the Test step).
#
# Usage: Scripts/test-report.sh [<results-dir>]
set -uo pipefail

results_dir="${1:-build/test-results}"

echo "## Resultado dos testes"
echo
echo "| Alvo | Total | Passaram | Falharam | Pulados |"
echo "| --- | ---: | ---: | ---: | ---: |"

total=0
passed=0
failed=0
skipped=0
found_any=false

emit_row() {
  local name="$1" t="$2" p="$3" f="$4" s="$5"
  local icon="✅"
  [[ "$f" != "0" ]] && icon="❌"
  echo "| $icon $name | $t | $p | $f | $s |"
  total=$((total + t))
  passed=$((passed + p))
  failed=$((failed + f))
  skipped=$((skipped + s))
  found_any=true
}

for bundle in "$results_dir"/*.xcresult; do
  [[ -d "$bundle" ]] || continue
  name="$(basename "$bundle" .xcresult)"
  summary="$(xcrun xcresulttool get test-results summary --path "$bundle" 2>/dev/null || true)"
  if [[ -z "$summary" ]]; then
    echo "| ⚠️ $name | ? | ? | ? | ? |"
    continue
  fi
  counts="$(echo "$summary" | python3 -c '
import json, sys
d = json.load(sys.stdin)
t = d.get("totalTestCount", 0)
p = d.get("passedTests", 0)
f = d.get("failedTests", 0)
s = d.get("skippedTests", 0)
print(t, p, f, s)
' 2>/dev/null || echo "")"
  if [[ -z "$counts" ]]; then
    echo "| ⚠️ $name | ? | ? | ? | ? |"
    continue
  fi
  # shellcheck disable=SC2086
  emit_row "$name" $counts
done

for xml in "$results_dir"/*.xml; do
  [[ -f "$xml" ]] || continue
  name="$(basename "$xml" .xml)"
  counts="$(python3 -c '
import sys
import xml.etree.ElementTree as ET
root = ET.parse(sys.argv[1]).getroot()
suites = [root] if root.tag == "testsuite" else root.findall("testsuite")
t = sum(int(s.get("tests", 0)) for s in suites)
f = sum(int(s.get("failures", 0)) + int(s.get("errors", 0)) for s in suites)
sk = sum(int(s.get("skipped", 0)) for s in suites)
print(t, t - f - sk, f, sk)
' "$xml" 2>/dev/null || echo "")"
  if [[ -z "$counts" ]]; then
    echo "| ⚠️ $name | ? | ? | ? | ? |"
    continue
  fi
  # shellcheck disable=SC2086
  emit_row "$name" $counts
done

echo
if [[ "$found_any" == false ]]; then
  echo "_Nenhum resultado de teste encontrado em \`$results_dir\`._"
else
  echo "**Total: $total testes — $passed passaram, $failed falharam, $skipped pulados.**"
fi
