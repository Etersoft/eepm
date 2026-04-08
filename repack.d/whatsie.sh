#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# generic-snap.sh removes bundled Qt from gnome-platform/,
# so we need to add dependencies on system Qt
add_libs_requires
