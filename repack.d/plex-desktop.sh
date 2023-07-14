#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

add_requires glib2 glxinfo libalsa libdbus libdrm libEGL libexpat fontconfig libfreetype libgbm libGLX libharfbuzz libjpeg8 liblcms2 libminizip libnspr libnss libOpenGL libopus libpci libpulseaudio libsnappy libtiff5 libudev1 libva libwayland-client libwayland-cursor libwayland-egl libwayland-server libX11 libxcb libxcb-render-util libxcbutil-icccm libxcbutil-image libxcbutil-keysyms libXcomposite libXdamage libXext libXfixes libXinerama libxkbcommon libxkbcommon-x11 libxkbfile libxml2 libXrandr libXrender libXScrnSaver libxshmfence libxslt libXtst which zlib

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

if epm assure patchelf ; then
for i in bin/Plex "bin/Plex Transcoder" ; do
    a= patchelf --set-rpath '$ORIGIN/../lib' "$i" || continue
done
for i in lib/lib*.so* ; do
    a= patchelf --set-rpath '$ORIGIN' "$i" || continue
done
fi

subst '1i%filter_from_requires /^libtiff.so.5(LIBTIFF_.*/d' $SPEC

exit 0
