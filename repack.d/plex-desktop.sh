#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/Plex.sh


cd .$PRODUCTDIR || fatal

for i in usr/lib/x86_64-linux-gnu/libwebp* ; do
    move_file $PRODUCTDIR/$i $PRODUCTDIR/lib/$(basename $i)
done

for i in etc meta snap lib/dri usr/bin usr/lib usr/include usr/share/X11 usr/share/misc usr/share/doc usr/share/fonts ; do
    remove_dir $PRODUCTDIR/$i
done

for i in libEGL.so.1 libdrm.so.2 libdrm_amdgpu.so.1 libva-drm.so.2 libva-x11.so.2 libva.so.2 ; do
    remove_file $PRODUCTDIR/lib/$i
done

cd >/dev/null

add_libs_requires
