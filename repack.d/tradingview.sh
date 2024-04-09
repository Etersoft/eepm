#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

add_bin_exec_command

# as in upstream's command.sh
subst 's|"$@"|--no-sandbox "$@"|' usr/bin/$PRODUCT

#fix_chrome_sandbox

add_libs_requires
