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

run_core() {
  echo "Core checks"
  
  while IFS= read -r f; do
    [[ "$f" == bin/* || "$f" == etc/* ]] || continue
    check_shell_syntax "$f"
  done <<< "$CHANGED_FILES_TEXT"

  bin/epm --version
  bin/epm --help >/dev/null
  bin/epm play --help >/dev/null
}

run_tests_component() {
  echo "Tests checks"
  while IFS= read -r f; do
    [[ "$f" == tests/* ]] || continue
    [[ "$f" == *.sh ]] || continue
    check_shell_syntax "$f"
  done <<< "$CHANGED_FILES_TEXT"
}

run_test_script_with_markers() {
  local script="$1"
  local out
  out="$(mktemp)"

  (cd tests && sh "$script") >"$out" 2>&1 || {
    cat "$out"
    rm -f "$out"
    return 1
  }

  cat "$out"
  if grep -Eq 'FATAL|FAILED|not equal' "$out"; then
    echo "Detected failure markers in tests/$script output."
    rm -f "$out"
    return 1
  fi

  rm -f "$out"
  return 0
}

run_tests_smoke() {
  echo "Tests smoke"
  run_test_script_with_markers test_glob.sh
  run_test_script_with_markers test_versions.sh
}

run_ci() {
  echo "CI checks"
  check_shell_syntax .github/ci/get-apps-to-test.sh
  check_shell_syntax .github/ci/detect-components.sh
  check_shell_syntax .github/ci/run-tests.sh
  check_shell_syntax .github/ci/run-component-tests.sh
  check_shell_syntax ci/run_one_ci.sh
}

case "$COMPONENT" in
  play)
    run_play
    ;;
  core)
    run_core
    ;;
  tests)
    run_tests_component
    ;;
  tests-smoke)
    run_tests_smoke
    ;;
  ci)
    run_ci
    ;;
  *)
    echo "Unknown component '$COMPONENT'"
    exit 1
    ;;
esac
