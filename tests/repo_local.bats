#!/usr/bin/env bats
# Tests for local repository operations: create, pkgadd, index, pkgupdate, pkgdel

# Path to epm (use from checkout if available)
EPM="${EPM:-$(dirname "$BATS_TEST_DIRNAME")/bin/epm}"

# Shared state file
BATS_TMPDIR="${BATS_TMPDIR:-/tmp}"
STATE_FILE="$BATS_TMPDIR/repo_local_test_state"

fatal() {
    echo "FATAL: $*" >&2
    exit 1
}

# Safe rm -rf: only delete paths within /tmp or /var/tmp
safe_rm_rf() {
    local path="$1"
    [ -z "$path" ] && return 0
    case "$path" in
        /tmp/*|/var/tmp/*)
            rm -rf "$path"
            ;;
        *)
            fatal "Refusing to delete '$path' - not in /tmp or /var/tmp!"
            ;;
    esac
}

setup_file() {
    # Check if we're on ALT Linux (these tests are ALT-specific)
    if ! "$EPM" print info -s | grep -q "alt"; then
        skip "Local repo tests only work on ALT Linux"
    fi

    # Ensure apt-repo-tools is installed for genbasedir
    "$EPM" assure genbasedir apt-repo-tools || skip "apt-repo-tools not available"

    # Create temp directory for test repo
    local test_repo="$(mktemp -d)"

    # Use existing noarch package or download one
    local test_pkg="$(ls ~/erc-*.noarch.rpm 2>/dev/null | head -1)"
    if [ ! -f "$test_pkg" ] ; then
        local pkg_dir="$(mktemp -d)"
        (cd "$pkg_dir" && "$EPM" --quiet download erc 2>/dev/null)
        test_pkg="$(ls "$pkg_dir"/*.rpm 2>/dev/null | head -1)"
        echo "PKG_DIR=$pkg_dir" >> "$STATE_FILE"
    fi

    [ -f "$test_pkg" ] || skip "Test package not found"
    local test_pkg_name="$("$EPM" print name for package "$test_pkg")"

    # Save state
    echo "TEST_REPO=$test_repo" > "$STATE_FILE"
    echo "TEST_PKG=$test_pkg" >> "$STATE_FILE"
    echo "TEST_PKG_NAME=$test_pkg_name" >> "$STATE_FILE"
}

teardown_file() {
    if [ -f "$STATE_FILE" ] ; then
        . "$STATE_FILE"
        safe_rm_rf "$TEST_REPO"
        safe_rm_rf "$PKG_DIR"
        rm -f "$STATE_FILE"
    fi
}

load_state() {
    [ -f "$STATE_FILE" ] && . "$STATE_FILE"
}

@test "repo create: creates directory structure" {
    load_state
    [ -n "$TEST_REPO" ] || skip "TEST_REPO not set"

    run "$EPM" repo create "$TEST_REPO" testrepo
    [ "$status" -eq 0 ]

    # Check that arch directories were created
    [ -d "$TEST_REPO/x86_64/RPMS.testrepo" ] || [ -d "$TEST_REPO/noarch/RPMS.testrepo" ]
}

@test "repo pkgadd: adds package to repository" {
    load_state
    [ -n "$TEST_PKG" ] || skip "No test package"
    [ -n "$TEST_REPO" ] || skip "TEST_REPO not set"

    run "$EPM" repo pkgadd "$TEST_REPO" "$TEST_PKG"
    [ "$status" -eq 0 ]

    # Check package was copied
    local found=$(find "$TEST_REPO" -name "*.rpm" | head -1)
    [ -n "$found" ]
}

@test "repo index: creates package index" {
    load_state
    [ -n "$TEST_REPO" ] || skip "TEST_REPO not set"

    run "$EPM" repo index "$TEST_REPO"
    [ "$status" -eq 0 ]

    # Check that pkglist files were created
    local found=$(find "$TEST_REPO" -name "pkglist.*" | head -1)
    [ -n "$found" ]
}

@test "repo pkgdel: removes package from repository" {
    load_state
    [ -n "$TEST_PKG_NAME" ] || skip "No test package name"
    [ -n "$TEST_REPO" ] || skip "TEST_REPO not set"

    # First verify package exists
    local before=$(find "$TEST_REPO" -name "*.rpm" | wc -l)
    [ "$before" -gt 0 ] || skip "No packages in repo"

    run "$EPM" repo pkgdel "$TEST_REPO" "$TEST_PKG_NAME"
    [ "$status" -eq 0 ]

    # Check package was removed
    local after=$(find "$TEST_REPO" -name "*.rpm" | wc -l)
    [ "$after" -lt "$before" ]
}

@test "repo pkgupdate: replaces package in repository" {
    load_state
    [ -n "$TEST_PKG" ] || skip "No test package"
    [ -n "$TEST_REPO" ] || skip "TEST_REPO not set"

    # Add package first
    "$EPM" repo pkgadd "$TEST_REPO" "$TEST_PKG"

    # Count packages before
    local before=$(find "$TEST_REPO" -name "*.rpm" | wc -l)

    # Update (should replace, not add)
    run "$EPM" repo pkgupdate "$TEST_REPO" "$TEST_PKG"
    [ "$status" -eq 0 ]

    # Count should be the same (replaced, not added)
    local after=$(find "$TEST_REPO" -name "*.rpm" | wc -l)
    [ "$after" -eq "$before" ]
}

@test "repo index after changes: updates index" {
    load_state
    [ -n "$TEST_REPO" ] || skip "TEST_REPO not set"

    run "$EPM" repo index "$TEST_REPO"
    [ "$status" -eq 0 ]
}
