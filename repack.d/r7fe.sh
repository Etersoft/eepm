#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=r7fe

. $(dirname $0)/common.sh

# upstream puts the binary to /usr/local/bin
move_file /usr/local/bin/$PRODUCT /usr/bin/$PRODUCT

add_libs_requires
