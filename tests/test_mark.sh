#!/bin/sh
# Integration tests for epm mark operations
# Run on test server: ssh epm@epm-sisyphus '~/eepm-bot/tests/test_mark.sh'
# Or locally if you have packages installed

TESTDIR="$(dirname "$0")"
EPM="${EPM:-$TESTDIR/../bin/epm}"

FAIL=0
PASS=0
TOTAL=0

# Use a real installed package and a virtual package
# On ALT: bash is always installed, webserver is virtual (provided by angie/nginx/etc.)
REAL_PKG="bash"
VIRTUAL_PKG="webserver"

assert_ok() {
    TOTAL=$((TOTAL + 1))
    if eval "$@" >/dev/null 2>&1 ; then
        PASS=$((PASS + 1))
        echo "  PASS: $TESTNAME"
    else
        FAIL=$((FAIL + 1))
        echo "  FAIL: $TESTNAME"
    fi
}

assert_fail() {
    TOTAL=$((TOTAL + 1))
    if eval "$@" >/dev/null 2>&1 ; then
        FAIL=$((FAIL + 1))
        echo "  FAIL: $TESTNAME (expected failure but succeeded)"
    else
        PASS=$((PASS + 1))
        echo "  PASS: $TESTNAME"
    fi
}

assert_output_contains() {
    local output="$1"
    local expected="$2"
    TOTAL=$((TOTAL + 1))
    if echo "$output" | grep -q "$expected" ; then
        PASS=$((PASS + 1))
        echo "  PASS: $TESTNAME"
    else
        FAIL=$((FAIL + 1))
        echo "  FAIL: $TESTNAME (output does not contain '$expected')"
    fi
}

assert_output_not_contains() {
    local output="$1"
    local expected="$2"
    TOTAL=$((TOTAL + 1))
    if echo "$output" | grep -q "$expected" ; then
        FAIL=$((FAIL + 1))
        echo "  FAIL: $TESTNAME (output contains '$expected' but should not)"
    else
        PASS=$((PASS + 1))
        echo "  PASS: $TESTNAME"
    fi
}

# Detect virtual package provider
VIRTUAL_RESOLVED="$($EPM query --short "$VIRTUAL_PKG" 2>/dev/null)"
if [ -z "$VIRTUAL_RESOLVED" ] ; then
    echo "WARNING: virtual package '$VIRTUAL_PKG' has no installed provider, skipping virtual package tests"
    SKIP_VIRTUAL=1
fi

# ============ mark help ============
echo "=== mark help ==="

TESTNAME="mark help shows usage"
output="$($EPM mark help 2>&1)"
assert_ok "echo '$output' | grep -qi 'mark\|hold\|manual'"

TESTNAME="mark --help works"
assert_ok "$EPM mark --help"

# ============ mark hold/unhold with real package ============
echo "=== mark hold/unhold (real package: $REAL_PKG) ==="

TESTNAME="hold real package"
assert_ok "$EPM mark hold $REAL_PKG"

TESTNAME="showhold includes real package"
output="$($EPM mark showhold 2>&1)"
assert_output_contains "$output" "$REAL_PKG"

TESTNAME="checkhold returns true for held package"
assert_ok "$EPM mark checkhold $REAL_PKG"

TESTNAME="unhold real package"
assert_ok "$EPM mark unhold $REAL_PKG"

TESTNAME="showhold does not include unholded package"
output="$($EPM mark showhold 2>&1)"
assert_output_not_contains "$output" "^${REAL_PKG}$"

# ============ mark hold/unhold with virtual package ============
if [ -z "$SKIP_VIRTUAL" ] ; then
echo "=== mark hold/unhold (virtual package: $VIRTUAL_PKG -> $VIRTUAL_RESOLVED) ==="

TESTNAME="hold virtual package"
assert_ok "$EPM mark hold $VIRTUAL_PKG"

TESTNAME="showhold includes resolved provider"
output="$($EPM mark showhold 2>&1)"
assert_output_contains "$output" "$VIRTUAL_RESOLVED"

TESTNAME="checkhold returns true for resolved provider"
assert_ok "$EPM mark checkhold $VIRTUAL_RESOLVED"

TESTNAME="unhold virtual package"
assert_ok "$EPM mark unhold $VIRTUAL_PKG"

TESTNAME="showhold does not include provider after unhold"
output="$($EPM mark showhold 2>&1)"
assert_output_not_contains "$output" "^${VIRTUAL_RESOLVED}$"
fi

# ============ mark hold with non-existent package ============
echo "=== mark hold (non-existent package) ==="

TESTNAME="hold non-existent package does not add to showhold"
$EPM mark hold nonexistent-package-eepm-test >/dev/null 2>&1
output="$($EPM mark showhold 2>&1)"
assert_output_not_contains "$output" "nonexistent-package-eepm-test"

# ============ mark auto/manual with real package ============
echo "=== mark auto/manual (real package: $REAL_PKG) ==="

TESTNAME="mark manual real package"
assert_ok "$EPM mark manual $REAL_PKG"

TESTNAME="mark auto real package"
assert_ok "$EPM mark auto $REAL_PKG"

# restore to manual
$EPM mark manual $REAL_PKG >/dev/null 2>&1

# ============ mark auto/manual with virtual package ============
if [ -z "$SKIP_VIRTUAL" ] ; then
echo "=== mark auto/manual (virtual package: $VIRTUAL_PKG -> $VIRTUAL_RESOLVED) ==="

TESTNAME="mark manual virtual package"
assert_ok "$EPM mark manual $VIRTUAL_PKG"

TESTNAME="mark auto virtual package"
assert_ok "$EPM mark auto $VIRTUAL_PKG"

# restore to manual
$EPM mark manual "$VIRTUAL_RESOLVED" >/dev/null 2>&1
fi

# ============ mark auto/manual with non-existent package ============
echo "=== mark auto/manual (non-existent package) ==="

TESTNAME="mark auto non-existent package fails"
assert_fail "$EPM mark auto nonexistent-package-eepm-test"

TESTNAME="mark manual non-existent package fails"
assert_fail "$EPM mark manual nonexistent-package-eepm-test"

# ============ mark showauto/showmanual ============
echo "=== mark showauto/showmanual ==="

TESTNAME="showauto runs without error"
assert_ok "$EPM mark showauto"

TESTNAME="showmanual runs without error"
assert_ok "$EPM mark showmanual"

# ============ Summary ============
echo
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
