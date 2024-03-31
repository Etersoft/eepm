#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_requires udev

add_libs_requires

fix_desktop_file /usr/bin/epsonscan2
