#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt /usr/lib/unityhub

add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCT

fix_desktop_file

# The bundled .NET licensing client probes optional lttng tracing support.
ignore_lib_requires liblttng-ust.so.0

add_electron_deps
