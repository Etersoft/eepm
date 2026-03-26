#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=codium

. $(dirname $0)/common.sh

move_to_opt

# libmsalruntime.so in microsoft-authentication extension links against libwebkit2gtk-4.1
# which is not available on older distros (c10f2, etc.)
ignore_lib_requires libwebkit2gtk-4.1.so.0

add_electron_deps

remove_file /usr/bin/$PRODUCT
add_bin_link_command

fix_desktop_file /usr/share/codium/codium


subst "s|^Group:.*|Group: Development/Tools|" $SPEC
