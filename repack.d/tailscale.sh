#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=tailscale
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

#opt and bin parts
move_to_opt /usr/bin

add_bin_exec_command
add_bin_exec_command tailscaled

#cleanup
remove_dir /var/cache
remove_dir /usr/lib/.build-id

add_libs_requires

