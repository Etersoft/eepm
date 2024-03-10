#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

add_bin_exec_command $PRODUCT
cat <<EOF >$BUILDROOT/usr/bin/$PRODUCT
#!/bin/sh
LD_LIBRARY_PATH=$PRODUCTDIR/$PRODUCT/lib/x86_64-linux-gnu exec $PRODUCTDIR/$PRODUCT --disable-gpu --no-sandbox "\$@"
EOF

cd .$PRODUCTDIR || fatal

for i in usr/lib/x86_64-linux-gnu/* ; do
    move_file $PRODUCTDIR/$i $PRODUCTDIR/lib/x86_64-linux-gnu/$(basename $i)
done

for i in etc meta snap lib/dri usr/bin usr/lib usr/include usr/share/X11 usr/share/misc usr/share/doc usr/share/fonts ; do
    remove_dir $PRODUCTDIR/$i
done

for i in libEGL.so.1 libdrm.so.2 libdrm_amdgpu.so.1 libva-drm.so.2 libva-x11.so.2 libva.so.2 ; do
    remove_file $PRODUCTDIR/lib/x86_64-linux-gnu/$i
done

for i in libdbus-1.so.3 libexpat.so.1 libkeyutils.so.1 libXss.so.1 libXss.so.1.0.0 ; do
    remove_file $PRODUCTDIR/lib/x86_64-linux-gnu/$i
done

cd >/dev/null

add_libs_requires
