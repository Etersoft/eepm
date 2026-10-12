#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_libs_requires

# procdump writes core dumps with gcore from gdb (as in original package)
add_unirequires /usr/bin/gcore
