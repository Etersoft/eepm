#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

# bundled dependencies not available in Sisyphus
ignore_lib_requires 'libedit.so.2' 'libwrap.so.0' 'libapparmor.so.1'

add_bin_link_command $PRODUCT $PRODUCTDIR/Plex.sh

