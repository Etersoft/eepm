#!/bin/bash
# Helper functions for epm-sh-* unit tests

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EPM_DIR="$(cd "$TESTS_DIR/../.." && pwd)"

# Minimal stubs for dependencies
echon() { printf "%s" "$*"; }
warning() { echo "warning: $*" >&2; }
info() { echo "$*" >&2; }
fatal() { echo "fatal: $*" >&2; return 1; }
showcmd() { :; }
docmd() { "$@"; }

# Default variables
PMTYPE="apt-rpm"
BASEDISTRNAME="alt"
DISTRARCH="x86_64"

# Load epm-sh-functions
load_epm_sh_functions() {
    . "$EPM_DIR/bin/epm-sh-functions"
}

# Load epm-sh-search (requires epm-sh-functions)
load_epm_sh_search() {
    load_epm_sh_functions
    . "$EPM_DIR/bin/epm-sh-search"
}

# Load epm-sh-altlinux (requires epm-sh-functions)
load_epm_sh_altlinux() {
    load_epm_sh_functions
    . "$EPM_DIR/bin/epm-sh-altlinux"
}
