#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

add_bin_exec_command

ignore_lib_requires libnode.so.72

add_requires '/usr/bin/node'

add_libs_requires
