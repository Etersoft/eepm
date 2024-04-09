#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT="$(grep "^Name: " $SPEC | sed -e "s|Name: ||g" | head -n1)"
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

cd .$PRODUCTDIR || fatal

# Workaround for plex
for i in usr/lib/x86_64-linux-gnu/libwebp* ; do
    move_file $PRODUCTDIR/$i $PRODUCTDIR/lib/$(basename $i)
done

for i in  data-dir gnome-platform scripts lib/dri usr etc meta snap ; do
    remove_dir $PRODUCTDIR/$i
done

for i in libEGL.so.1 libdrm.so.2 libdrm_amdgpu.so.1 libva-drm.so.2 libva-x11.so.2 libva.so.2 libcom_err.so.2 libdbus-1.so.3 libexpat.so.1 libkeyutils.so.1 ; do
    remove_file $PRODUCTDIR/lib/$i
done

for i in command.sh desktop-common.sh desktop-gnome-specific.sh desktop-init.sh ; do
    remove_file $PRODUCTDIR/$i
done

cd >/dev/null
