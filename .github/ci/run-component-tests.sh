#!/usr/bin/env bash
set -euo pipefail

COMPONENT="${COMPONENT:?COMPONENT is not set}"
APPS_TEXT="${APPS_TEXT:-}"
CHANGED_FILES_TEXT="${CHANGED_FILES_TEXT:-}"

check_shell_syntax() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  [[ -r "$f" ]] || return 0

  if head -n1 "$f" | grep -q 'bash'; then
    bash -n "$f"
  else
    sh -n "$f"
  fi
}

run_play() {
  if [[ -z "$APPS_TEXT" ]]; then
    echo "APPS_TEXT is empty for play component; nothing to run."
    return 0
  fi

  ./.github/ci/run-tests.sh
}

run_smoke() {
  echo "Smoke: shell syntax"
  while IFS= read -r f; do
    case "$f" in
      bin/*|etc/*) check_shell_syntax "$f" ;;
      tests/*.sh)  check_shell_syntax "$f" ;;
    esac
  done <<< "$CHANGED_FILES_TEXT"

  echo "Smoke: epm entrypoint"
  bin/epm --version
  bin/epm --help >/dev/null
  bin/epm play --help >/dev/null

  echo "Smoke: unit tests and popular epm commands"
  sh .github/ci/ci-smoke-test.sh
}

validate_components_map() {
  local map=".github/ci/components.map"
  local lineno=0 comp paths systems line rc=0

  [[ -r "$map" ]] || { echo "components.map is not readable: $map"; return 1; }

  while IFS= read -r line || [[ -n "$line" ]]; do
    lineno=$((lineno + 1))
    [[ -z "${line// }" ]] && continue
    [[ "${line#"${line%%[![:space:]]*}"}" == \#* ]] && continue

    local pipes="${line//[^|]}"
    if (( ${#pipes} != 2 )); then
      echo "components.map:$lineno: expected 2 '|' separators, got ${#pipes}: $line"
      rc=1; continue
    fi

    IFS='|' read -r comp paths systems <<< "$line"
    comp="${comp## }"; comp="${comp%% }"
    paths="${paths## }"; paths="${paths%% }"
    systems="${systems## }"; systems="${systems%% }"

    if [[ -z "$comp" || -z "$paths" || -z "$systems" ]]; then
      echo "components.map:$lineno: empty field(s): comp='$comp' paths='$paths' systems='$systems'"
      rc=1
    fi
  done < "$map"

  return "$rc"
}

run_ci() {
  echo "CI checks"
  check_shell_syntax .github/ci/get-apps-to-test.sh
  check_shell_syntax .github/ci/detect-components.sh
  check_shell_syntax .github/ci/run-tests.sh
  check_shell_syntax .github/ci/run-component-tests.sh
  check_shell_syntax .github/ci/ci-smoke-test.sh
  check_shell_syntax ci/run_one_ci.sh

  echo "components.map format"
  validate_components_map
}

case "$COMPONENT" in
  play)
    run_play
    ;;
  smoke)
    run_smoke
    ;;
  ci)
    run_ci
    ;;
  *)
    echo "Unknown component '$COMPONENT'"
    exit 1
    ;;
esac
