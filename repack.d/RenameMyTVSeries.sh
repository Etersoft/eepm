#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

#add_unirequires libcrypto.so

add_requires libssl-devel

fix_desktop_file /usr/share/RenameMyTVSeries/RenameMyTVSeries RenameMyTVSeries
