#!/bin/sh
# Test shell completion scripts

TESTDIR="$(dirname "$0")"
BASEDIR="$(dirname "$TESTDIR")"
COMPLETIONS="$BASEDIR/completions"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

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

# Test: bash completion syntax
test_bash_syntax() {
    if command -v bash >/dev/null 2>&1 ; then
        if bash -n "$COMPLETIONS/bash/eepm" 2>/dev/null ; then
            pass "bash/eepm syntax is valid"
        else
            fail "bash/eepm has syntax errors"
        fi
        if bash -n "$COMPLETIONS/bash/serv" 2>/dev/null ; then
            pass "bash/serv syntax is valid"
        else
            fail "bash/serv has syntax errors"
        fi
    else
        echo "SKIP: bash not available"
    fi
}

# Test: zsh completion syntax
test_zsh_syntax() {
    if command -v zsh >/dev/null 2>&1 ; then
        if zsh -n "$COMPLETIONS/zsh/_eepm" 2>/dev/null ; then
            pass "zsh/_eepm syntax is valid"
        else
            fail "zsh/_eepm has syntax errors"
        fi
        if zsh -n "$COMPLETIONS/zsh/_serv" 2>/dev/null ; then
            pass "zsh/_serv syntax is valid"
        else
            fail "zsh/_serv has syntax errors"
        fi
    else
        echo "SKIP: zsh not available"
    fi
}

# Test: fish completion syntax
test_fish_syntax() {
    if command -v fish >/dev/null 2>&1 ; then
        if fish -n "$COMPLETIONS/fish/eepm.fish" 2>/dev/null ; then
            pass "fish/eepm.fish syntax is valid"
        else
            fail "fish/eepm.fish has syntax errors"
        fi
    else
        echo "SKIP: fish not available"
    fi
}

# Test: fish symlinks exist and are valid
test_fish_symlinks() {
    local symlinks="epmi epmI epme epmq epmqa epmqf epmqp epmqi epmql epmqcl epmu epmU epms epmsf epmcl epmp epmrp epm epmps"
    for name in $symlinks ; do
        local link="$COMPLETIONS/fish/${name}.fish"
        if [ -L "$link" ] ; then
            if [ -e "$link" ] ; then
                pass "fish/$name.fish symlink is valid"
            else
                fail "fish/$name.fish symlink is broken"
            fi
        else
            fail "fish/$name.fish symlink is missing"
        fi
    done
}

# Test: bash completion can be sourced
test_bash_source() {
    if command -v bash >/dev/null 2>&1 ; then
        if bash -c "source '$COMPLETIONS/bash/eepm' && type __eepm >/dev/null 2>&1" 2>/dev/null ; then
            pass "bash/eepm can be sourced and defines __eepm"
        else
            fail "bash/eepm cannot be sourced or __eepm not defined"
        fi
    else
        echo "SKIP: bash not available"
    fi
}

# Test: fish completion can be sourced and provides completions
test_fish_source() {
    if command -v fish >/dev/null 2>&1 ; then
        # Check that sourcing works and provides some completions
        local result
        result=$(fish -c "source '$COMPLETIONS/fish/eepm.fish'; complete -C 'epm '" 2>/dev/null)
        if [ -n "$result" ] ; then
            pass "fish/eepm.fish provides completions"
        else
            fail "fish/eepm.fish does not provide completions"
        fi
    else
        echo "SKIP: fish not available"
    fi
}

# Run all tests
echo "=== Testing shell completion scripts ==="
echo

test_bash_syntax
test_zsh_syntax
test_fish_syntax
test_fish_symlinks
test_bash_source
test_fish_source

echo
echo "=== Results: $PASSED passed, $FAILED failed ==="

[ $FAILED -eq 0 ]
