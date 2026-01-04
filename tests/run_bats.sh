#!/bin/sh
# Runner for bats tests
# Usage: ./run_bats.sh [test_file.bats ...]
# Without arguments runs all .bats files

TESTDIR="$(dirname "$0")"
EPM="$TESTDIR/../bin/epm"

# Ensure bats is installed
if ! command -v bats >/dev/null 2>&1 ; then
    echo "Installing bats..."
    "$EPM" --auto install bats bats-assert bats-support || exit 1
fi

cd "$TESTDIR" || exit 1

if [ -n "$1" ] ; then
    # Run specified tests
    exec bats "$@"
else
    # Run all bats tests
    exec bats *.bats
fi
