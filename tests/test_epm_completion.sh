#!/bin/sh
# Test epm tool epm-completion

TESTDIR="$(dirname "$0")"
BASEDIR="$(dirname "$TESTDIR")"

# Use local epm
EPM="$BASEDIR/bin/epm"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

FAILED=0
PASSED=0

pass() {
    PASSED=$((PASSED + 1))
    printf "${GREEN}PASS${NC}: %s\n" "$1"
}

fail() {
    FAILED=$((FAILED + 1))
    printf "${RED}FAIL${NC}: %s\n" "$1"
}

# Test: commands output contains expected commands
test_commands() {
    output=$($EPM tool epm-completion commands 2>/dev/null)

    # Check for essential commands (rm is alias for remove)
    for cmd in install rm search play repo update upgrade; do
        if echo "$output" | grep -q "^$cmd	"; then
            pass "commands contains '$cmd'"
        else
            fail "commands missing '$cmd'"
        fi
    done

    # Check TSV format (command<TAB>description)
    if echo "$output" | head -1 | grep -q '	'; then
        pass "commands output is TSV format"
    else
        fail "commands output is not TSV format"
    fi
}

# Test: options output contains expected options
test_options() {
    output=$($EPM tool epm-completion options 2>/dev/null)

    # Check for essential options
    for opt in "--verbose" "--quiet" "--debug" "-y"; do
        if echo "$output" | grep -q "^$opt	"; then
            pass "options contains '$opt'"
        else
            fail "options missing '$opt'"
        fi
    done
}

# Test: aliases output
test_aliases() {
    output=$($EPM tool epm-completion aliases 2>/dev/null)

    # Check for essential aliases
    for alias in epmi epme epmp epmql; do
        if echo "$output" | grep -q "^$alias	"; then
            pass "aliases contains '$alias'"
        else
            fail "aliases missing '$alias'"
        fi
    done
}

# Test: repos output (repo/package install prefixes)
test_repos() {
    output=$($EPM tool epm-completion repos 2>/dev/null)

    # Check for essential repo prefixes (with trailing slash)
    for repo in "sisyphus/" "p10/" "p11/"; do
        if echo "$output" | grep -q "^$repo\$"; then
            pass "repos contains '$repo'"
        else
            fail "repos missing '$repo'"
        fi
    done
}

# Test: repo subcommand options
test_repo_subcommand() {
    output=$($EPM tool epm-completion repo 2>/dev/null)

    # Check for essential repo subcommands
    for subcmd in list add enable disable set switch; do
        if echo "$output" | grep -q "^$subcmd	"; then
            pass "repo subcommands contains '$subcmd'"
        else
            fail "repo subcommands missing '$subcmd'"
        fi
    done
}

# Test: mark subcommand options
test_mark_subcommand() {
    output=$($EPM tool epm-completion mark 2>/dev/null)

    # Check for essential mark subcommands
    for subcmd in hold unhold showhold showauto showmanual; do
        if echo "$output" | grep -q "^$subcmd	"; then
            pass "mark subcommands contains '$subcmd'"
        else
            fail "mark subcommands missing '$subcmd'"
        fi
    done
}

# Test: play options
test_play_options() {
    output=$($EPM tool epm-completion play 2>/dev/null)

    # Check for essential play options
    for opt in "--list" "--remove" "--update"; do
        if echo "$output" | grep -q "^$opt	"; then
            pass "play options contains '$opt'"
        else
            fail "play options missing '$opt'"
        fi
    done
}

# Test: status options
test_status_options() {
    output=$($EPM tool epm-completion status 2>/dev/null)

    # Check for essential status options
    for opt in "--installed" "--original" "--signed"; do
        if echo "$output" | grep -q "^$opt	"; then
            pass "status options contains '$opt'"
        else
            fail "status options missing '$opt'"
        fi
    done
}

# Test: argument types in commands output (third column)
test_argument_types() {
    output=$($EPM tool epm-completion commands 2>/dev/null)

    # Check that install has 'package' type
    if echo "$output" | grep -q "^install	.*	package$"; then
        pass "install has argtype 'package'"
    else
        fail "install missing argtype 'package'"
    fi

    # Check that rm has 'package_installed' type
    if echo "$output" | grep -q "^rm	.*	package_installed$"; then
        pass "rm has argtype 'package_installed'"
    else
        fail "rm missing argtype 'package_installed'"
    fi

    # Check that play has 'playapp' type
    if echo "$output" | grep -q "^play	.*	playapp$"; then
        pass "play has argtype 'playapp'"
    else
        fail "play missing argtype 'playapp'"
    fi

    # Check that repo has 'repo' type
    if echo "$output" | grep -q "^repo	.*	repo$"; then
        pass "repo has argtype 'repo'"
    else
        fail "repo missing argtype 'repo'"
    fi

    # Check that repack has 'file' type
    if echo "$output" | grep -q "^repack	.*	file$"; then
        pass "repack has argtype 'file'"
    else
        fail "repack missing argtype 'file'"
    fi

    # Check that prescription has 'prescription' type
    if echo "$output" | grep -q "^prescription	.*	prescription$"; then
        pass "prescription has argtype 'prescription'"
    else
        fail "prescription missing argtype 'prescription'"
    fi

    # Check that search has no argtype (no third column)
    if echo "$output" | grep "^search	" | grep -qv "	.*	"; then
        pass "search has no argtype"
    else
        fail "search should not have argtype"
    fi
}

# Run all tests
echo "=== Testing epm tool epm-completion ==="
echo

test_commands
test_options
test_aliases
test_repos
test_repo_subcommand
test_mark_subcommand
test_play_options
test_status_options
test_argument_types

echo
echo "=== Results: $PASSED passed, $FAILED failed ==="

[ $FAILED -eq 0 ]
