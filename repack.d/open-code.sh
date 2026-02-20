#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# Fix empty License field from original package
subst "s|^License:.*|License: MIT|" $SPEC

# Fix empty Categories
fix_desktop_file "Categories=" "Categories=Development;IDE;"
