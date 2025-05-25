#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_unirequires libappindicator3.so.1
add_unirequires vlc-mini

add_libs_requires
