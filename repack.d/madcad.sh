#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_exec_command

add_requires "python3(madcad)" "python3(glcontext)"

add_libs_requires
