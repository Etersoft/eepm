#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_libs_requires
add_electron_deps
fix_chrome_sandbox
add_bin_exec_command $PRODUCT $PRODUCTDIR/losslesscut
