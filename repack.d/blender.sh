#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_link_command blender $PRODUCTDIR/blender-launcher
add_bin_link_command blender-softwaregl $PRODUCTDIR/blender-softwaregl
add_bin_link_command blender-system-info $PRODUCTDIR/blender-system-info.sh
add_bin_link_command blender-thumbnailer $PRODUCTDIR/blender-thumbnailer

ignore_lib_requires libamdhip64.so.6 libze_loader.so.1

