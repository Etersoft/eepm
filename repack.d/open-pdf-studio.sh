#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

fix_desktop_file "Categories=.*" "Categories=Office;Viewer;"
