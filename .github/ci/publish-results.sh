#!/usr/bin/env bash
set -euo pipefail

APPS_TEXT="${APPS_TEXT:-}"
TEST_TARGET="${TEST_TARGET:-play}"
TEST_SYSTEM="${TEST_SYSTEM:-unknown}"
ARTIFACT_NAME="${ARTIFACT_NAME:-epm-results}"
SUMMARY_FILE="${GITHUB_STEP_SUMMARY:-}"

find_result_file() {
  local directory="$1"
  local app="$2"

  find epm-results -type f -path "*/$directory/$app.log" -print -quit 2>/dev/null || true
}

extract_failure_reason() {
  local log_file="$1"
  local pattern reason=''

  for pattern in \
    '^FATAL:' \
    '^E: ' \
    '^WARNING: Can.t find converted' \
    '^ERROR:' \
    'There was some error during'; do
    reason="$({
      sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' "$log_file" | \
        grep -E "$pattern" | tail -n 1
    } || true)"
    [[ -z "$reason" ]] || break
  done

  reason="${reason//$'\r'/}"
  reason="${reason//$'\n'/ }"
  reason="${reason//\`/\'}"
  reason="${reason//|/\\|}"
  printf '%s' "${reason:-See the attached error log}"
}

escape_command_data() {
  local value="$1"

  value="${value//%/%25}"
  value="${value//$'\r'/%0D}"
  value="${value//$'\n'/%0A}"
  printf '%s' "$value"
}

escape_command_property() {
  local value="$1"

  value="$(escape_command_data "$value")"
  value="${value//:/%3A}"
  value="${value//,/%2C}"
  printf '%s' "$value"
}

emit_annotation() {
  local level="$1"
  local title="$2"
  local message="$3"

  printf '::%s title=%s::%s\n' \
    "$level" \
    "$(escape_command_property "$title")" \
    "$(escape_command_data "$message")"
}

if [[ -z "$SUMMARY_FILE" ]]; then
  echo "GITHUB_STEP_SUMMARY is not set; skipping summary"
  exit 0
fi

{
  printf "## PR test: \`%s\` @ \`%s\`\n\n" "$TEST_TARGET" "$TEST_SYSTEM"
  printf "| Application | Result | Details |\n"
  printf "| --- | --- | --- |\n"
} >> "$SUMMARY_FILE"

while IFS= read -r app; do
  [[ -n "$app" ]] || continue

  error_log="$(find_result_file epm-errors "$app")"
  success_log="$(find_result_file epm-logs "$app")"

  if [[ -n "$error_log" ]]; then
    reason="$(extract_failure_reason "$error_log")"
    printf "| \`%s\` | **FAIL** | \`%s\` |\n" "$app" "$reason" >> "$SUMMARY_FILE"
    emit_annotation error "PR test: $app @ $TEST_SYSTEM" "FAIL: $reason"
  elif [[ -n "$success_log" ]]; then
    printf "| \`%s\` | **PASS** | Completed successfully |\n" "$app" >> "$SUMMARY_FILE"
    emit_annotation notice "PR test: $app @ $TEST_SYSTEM" 'PASS: completed successfully'
  else
    printf "| \`%s\` | **NOT RUN** | No test log was produced |\n" "$app" >> "$SUMMARY_FILE"
    emit_annotation warning "PR test: $app @ $TEST_SYSTEM" 'NOT RUN: no test log was produced'
  fi
done <<< "$APPS_TEXT"

printf "\nFull logs and package metadata: artifact \`%s\`.\n" "$ARTIFACT_NAME" >> "$SUMMARY_FILE"
