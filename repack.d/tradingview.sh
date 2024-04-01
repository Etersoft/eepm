#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

add_bin_link_command


cd .$PRODUCTDIR || fatal


for i in etc meta snap lib/dri usr/bin usr/lib usr/include usr/share/X11 usr/share/misc usr/share/doc usr/share/fonts ; do
    remove_dir $PRODUCTDIR/$i
done

cd >/dev/null

add_libs_requires
