#!/bin/sh
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TESTS_DIR="$REPO_ROOT/tests"
EPM="$REPO_ROOT/bin/epm"

FAILURE_MARKERS='FATAL|FAILED|not equal|NOT EQUAL'

failed=0
total=0
summary=""

record() {
    summary="${summary}${1}	${2}
"
    [ "$1" = "pass" ] || failed=$((failed + 1))
}

[ -d "$TESTS_DIR" ] || { echo "[ci-smoke] tests/ not found: $TESTS_DIR" >&2; exit 2; }


for t in test_versions.sh test_glob.sh test_distr_info.sh test_startwith.sh test_sections.sh ; do
    total=$((total + 1))

    if [ ! -f "$TESTS_DIR/$t" ] ; then
        echo "[ci-smoke] MISS unit $t"
        record MISS "unit $t"
        continue
    fi

    echo "[ci-smoke] --- unit $t ---"
    out="$(cd "$TESTS_DIR" && sh "$t" 2>&1)"
    rc=$?
    printf '%s\n' "$out"

    if [ "$rc" -ne 0 ] ; then
        echo "[ci-smoke] unit $t exited $rc"
        record FAIL "unit $t (exit $rc)"
        continue
    fi

    if printf '%s' "$out" | grep -Eq "$FAILURE_MARKERS" ; then
        echo "[ci-smoke] unit $t produced failure markers"
        record FAIL "unit $t (markers)"
        continue
    fi

    record pass "unit $t"
done


run_epm_cmd() {
    total=$((total + 1))
    label="epm $*"

    echo "[ci-smoke] --- cmd $label ---"
    out="$("$EPM" "$@" 2>&1)"
    rc=$?
    printf '%s\n' "$out" | head -n 15
    nlines="$(printf '%s\n' "$out" | wc -l)"
    [ "$nlines" -gt 15 ] && echo "[ci-smoke] (output truncated, $nlines lines total)"

    if [ "$rc" -ne 0 ] ; then
        echo "[ci-smoke] cmd '$label' exited $rc"
        record FAIL "cmd $label (exit $rc)"
        return
    fi

    record pass "cmd $label"
}
run_epm_cmd update
run_epm_cmd search bash
run_epm_cmd cl bash
run_epm_cmd info bash
run_epm_cmd provides /bin/bash

#Install lifecycle: install mc, inspect mc, remove mc
run_epm_cmd --auto install mc
run_epm_cmd qf /usr/bin/mc
run_epm_cmd ql mc
run_epm_cmd --auto remove mc

echo
echo "[ci-smoke] === summary ($((total - failed))/$total passed) ==="
printf '%s' "$summary"

[ "$failed" -eq 0 ] || exit 1
exit 0
