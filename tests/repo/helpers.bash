#!/bin/bash
# Helper functions for epm repo tests

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES_DIR="$TESTS_DIR/fixtures"
EPM_BIN="$(cd "$TESTS_DIR/../.." && pwd)/bin/epm"

# Setup isolated test environment
setup_test_root() {
    TEST_ROOT=$(mktemp -d)
    mkdir -p "$TEST_ROOT/etc/apt/sources.list.d"
    export EPM_APT_SOURCES_ROOT="$TEST_ROOT"
}

# Cleanup test environment
teardown_test_root() {
    if [ -n "$TEST_ROOT" ] && [ -d "$TEST_ROOT" ]; then
        rm -rf "$TEST_ROOT"
    fi
    unset EPM_APT_SOURCES_ROOT
}

# Copy fixture to test root
use_fixture() {
    local fixture="$1"
    cp "$FIXTURES_DIR/$fixture" "$TEST_ROOT/etc/apt/sources.list"
}

# Copy sources.list.d fixture
use_fixture_d() {
    local fixture="$1"
    cp "$FIXTURES_DIR/sources.list.d/$fixture" "$TEST_ROOT/etc/apt/sources.list.d/"
}

# Run epm with test environment
run_epm() {
    EPM_APT_SOURCES_ROOT="$TEST_ROOT" "$EPM_BIN" "$@"
}

# Count active repos (non-comment lines)
count_active_repos() {
    grep -v '^#' "$TEST_ROOT/etc/apt/sources.list" 2>/dev/null | grep -c '^rpm'
}

# Check if repo line exists (fixed string)
repo_exists() {
    grep -qF "$1" "$TEST_ROOT/etc/apt/sources.list" 2>/dev/null
}

# Check if repo is commented (fixed string)
repo_commented() {
    grep -qF "$1" "$TEST_ROOT/etc/apt/sources.list" 2>/dev/null && \
    grep -q "^#.*$1" "$TEST_ROOT/etc/apt/sources.list" 2>/dev/null
}
