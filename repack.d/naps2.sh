#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt

add_bin_link_command
fix_desktop_file

ignore_lib_requires libmscordaccore.so

add_libs_requires
