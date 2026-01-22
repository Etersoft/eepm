#!/bin/sh
#
# Tests for epm override command
#

set -e

TESTDIR=$(dirname "$0")
EPM="${TESTDIR}/../bin/epm"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

passed=0
failed=0

pass() {
    echo "${GREEN}PASS${NC}: $1"
    passed=$((passed + 1))
}

fail() {
    echo "${RED}FAIL${NC}: $1"
    failed=$((failed + 1))
}

# Test help
test_help() {
    if $EPM override --help | grep -q 'restrict application execution' ; then
        pass "override --help"
    else
        fail "override --help"
    fi
}

# Test list when empty (non-dpkg systems)
test_list_empty() {
    # Skip on dpkg systems
    if which dpkg-statoverride >/dev/null 2>&1 ; then
        pass "list empty (skipped on dpkg)"
        return
    fi

    if $EPM override list 2>&1 | grep -q 'No overrides configured' ; then
        pass "list empty"
    else
        fail "list empty"
    fi
}

# Test add with nonexistent group
test_add_nonexistent_group() {
    if ! $EPM override add nonexistent_test_group_12345 /usr/bin/ls 2>&1 | grep -q 'does not exist' ; then
        fail "add nonexistent group"
    else
        pass "add nonexistent group"
    fi
}

# Test add with nonexistent file
test_add_nonexistent_file() {
    if ! $EPM override add users /nonexistent/path/binary 2>&1 | grep -q 'does not exist' ; then
        fail "add nonexistent file"
    else
        pass "add nonexistent file"
    fi
}

# Test add with non-absolute path
test_add_relative_path() {
    if $EPM override add users relative/path 2>&1 | grep -q 'must be absolute' ; then
        pass "add relative path"
    else
        fail "add relative path"
    fi
}

# Test add with non-executable file
test_add_non_executable() {
    if $EPM override add users /etc/passwd 2>&1 | grep -q 'not an executable' ; then
        pass "add non-executable"
    else
        fail "add non-executable"
    fi
}

# Test add with wrong permissions
test_add_wrong_permissions() {
    # Find an executable with non-755 permissions (e.g. setgid like /usr/bin/wall)
    local testfile=""
    for f in /usr/bin/wall /usr/bin/write /usr/bin/chage ; do
        if [ -x "$f" ] ; then
            local mode=$(stat -c '%a' "$f" 2>/dev/null)
            # Look for setgid (2xxx) or other non-755/4755 modes
            case "$mode" in
                755|4755|750|4750) continue ;;
                *) testfile="$f" ; break ;;
            esac
        fi
    done

    if [ -n "$testfile" ] ; then
        if $EPM override add users "$testfile" 2>&1 | grep -q 'expected 755' ; then
            pass "add wrong permissions"
        else
            fail "add wrong permissions"
        fi
    else
        pass "add wrong permissions (skipped, no suitable test file)"
    fi
}

# Test full cycle (requires root)
test_full_cycle() {
    if [ "$(id -u)" != "0" ] ; then
        pass "full cycle (skipped, need root)"
        return
    fi

    # Check if users group exists
    if ! getent group users >/dev/null 2>&1 ; then
        pass "full cycle (skipped, no users group)"
        return
    fi

    local testbin="/usr/bin/ls"
    local orig_mode=$(stat -c '%a' "$testbin")
    local orig_group=$(stat -c '%G' "$testbin")

    # Only test if permissions are 755
    if [ "$orig_mode" != "755" ] ; then
        pass "full cycle (skipped, $testbin has mode $orig_mode)"
        return
    fi

    # Add override
    $EPM override add users "$testbin" || { fail "full cycle - add" ; return ; }

    # Check permissions changed
    local new_mode=$(stat -c '%a' "$testbin")
    local new_group=$(stat -c '%G' "$testbin")

    if [ "$new_mode" = "750" ] && [ "$new_group" = "users" ] ; then
        pass "full cycle - permissions applied"
    else
        fail "full cycle - permissions (got $new_mode $new_group)"
    fi

    # Check in list
    if $EPM override list | grep -q "$testbin" ; then
        pass "full cycle - in list"
    else
        fail "full cycle - in list"
    fi

    # Remove override
    $EPM override remove "$testbin" || { fail "full cycle - remove" ; return ; }

    # Restore original permissions
    chmod "$orig_mode" "$testbin"
    chown "root:$orig_group" "$testbin"

    pass "full cycle - complete"
}

# Run tests
echo "=== epm override tests ==="
echo

test_help
test_list_empty
test_add_nonexistent_group
test_add_nonexistent_file
test_add_relative_path
test_add_non_executable
test_add_wrong_permissions
test_full_cycle

echo
echo "=== Results: $passed passed, $failed failed ==="

[ $failed -eq 0 ]
