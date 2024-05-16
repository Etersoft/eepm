#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_requires i586-alsa-plugins-pulse.32bit i586-libnsl1.32bit

fix_desktop_file /usr/bin/$PRODUCT

add_libs_requires
