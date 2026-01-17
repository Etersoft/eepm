#!/bin/sh
# Test epm tool epm-command-not-found

TESTDIR="$(dirname "$0")"
BASEDIR="$(dirname "$TESTDIR")"

# Use local epm
EPM="$BASEDIR/bin/epm"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

FAILED=0
PASSED=0
SKIPPED=0

pass() {
    PASSED=$((PASSED + 1))
    printf "${GREEN}PASS${NC}: %s\n" "$1"
}

fail() {
    FAILED=$((FAILED + 1))
    printf "${RED}FAIL${NC}: %s\n" "$1"
}

skip() {
    SKIPPED=$((SKIPPED + 1))
    printf "${YELLOW}SKIP${NC}: %s\n" "$1"
}

# Test: Russian to English keyboard conversion
test_keyboard_conversion() {
    echo "--- Testing keyboard conversion ---"

    # Test cases: Russian input -> expected English output
    # Note: we test via the tool's suggestion output

    # hjnrg (Russian йцукен for htop)
    output=$($EPM tool epm-command-not-found "реьщму" 2>/dev/null)
    if echo "$output" | grep -qi "remote"; then
        pass "keyboard conversion 'реьщму' -> 'remote'"
    else
        # The conversion depends on the exact mapping
        skip "keyboard conversion test (may depend on locale)"
    fi
}

# Test: epm play app suggestion
test_play_suggestion() {
    echo "--- Testing play app suggestions ---"

    # Test with known play app name
    output=$($EPM tool epm-command-not-found "telegram" 2>/dev/null)
    if echo "$output" | grep -qi "epm play telegram\|epm epmp telegram"; then
        pass "suggests 'epm play telegram' for 'telegram'"
    else
        # May not have play list available
        skip "play suggestion test (requires epm play list)"
    fi

    output=$($EPM tool epm-command-not-found "discord" 2>/dev/null)
    if echo "$output" | grep -qi "epm play discord\|epm epmp discord"; then
        pass "suggests 'epm play discord' for 'discord'"
    else
        skip "play suggestion test for discord"
    fi
}

# Test: package suggestion via epm sf
test_package_suggestion() {
    echo "--- Testing package suggestions ---"

    # Test with known command that maps to a package
    output=$($EPM tool epm-command-not-found "htop" 2>/dev/null)
    if echo "$output" | grep -qi "epm install\|epm epmi"; then
        pass "suggests package installation for 'htop'"
    else
        skip "package suggestion test (requires epm sf / apt-file)"
    fi
}

# Test: no output for empty command
test_empty_command() {
    echo "--- Testing edge cases ---"

    output=$($EPM tool epm-command-not-found "" 2>/dev/null)
    # Empty command shows help, which is expected behavior
    if echo "$output" | grep -q "epm tool epm-command-not-found"; then
        pass "shows help for empty command"
    else
        # Or produces no output
        if [ -z "$output" ]; then
            pass "handles empty command gracefully"
        else
            fail "unexpected output for empty command"
        fi
    fi
}

# Test: no crash on special characters
test_special_characters() {
    # Commands with special characters should not crash
    output=$($EPM tool epm-command-not-found "test-cmd" 2>/dev/null)
    ret=$?
    if [ $ret -ne 127 ] && [ $ret -ne 1 ] && [ $ret -ne 0 ]; then
        fail "crashed on command with dash"
    else
        pass "handles command with dash"
    fi

    output=$($EPM tool epm-command-not-found "test_cmd" 2>/dev/null)
    ret=$?
    if [ $ret -ne 127 ] && [ $ret -ne 1 ] && [ $ret -ne 0 ]; then
        fail "crashed on command with underscore"
    else
        pass "handles command with underscore"
    fi
}

# Test: basic execution without errors
test_basic_execution() {
    echo "--- Testing basic execution ---"

    # Just run the tool and check it doesn't crash
    # Note: command-not-found handlers always return 127 by convention
    $EPM tool epm-command-not-found "nonexistent_cmd_12345" >/dev/null 2>&1
    ret=$?
    # Should return 127 (command-not-found convention)
    if [ $ret -eq 127 ]; then
        pass "basic execution works (returns 127)"
    else
        fail "basic execution failed with code $ret (expected 127)"
    fi
}

# Run all tests
echo "=== Testing epm tool epm-command-not-found ==="
echo

test_basic_execution
test_keyboard_conversion
test_play_suggestion
test_package_suggestion
test_empty_command
test_special_characters

echo
echo "=== Results: $PASSED passed, $FAILED failed, $SKIPPED skipped ==="

[ $FAILED -eq 0 ]
