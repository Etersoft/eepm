#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

ignore_lib_requires libimagepro

add_libs_requires

fix_desktop_file
add_bin_exec_command
