#!/bin/bash
# Helper functions for epm search tests

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EPM_BIN="$(cd "$TESTS_DIR/../.." && pwd)/bin/epm"

# Run epm search
run_epm() {
    "$EPM_BIN" "$@" 2>/dev/null
}
