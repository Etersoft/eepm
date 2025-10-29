#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/svp4

. $(dirname $0)/common.sh


# pack icons
for i in  32 48 64 128 ; do
    [ -r $BUILDROOT/$PRODUCTDIR/svp-manager4-$i.png ] || continue
    mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
    cp $BUILDROOT/$PRODUCTDIR/svp-manager4-$i.png $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/svp-manager4.png
done
subst "s|%files|%files\n/usr/share/icons/hicolor/*x*/apps/svp-manager4.png|" $SPEC

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=SVP 4 Linux
GenericName=Real time frame interpolation
Type=Application
Categories=Multimedia;AudioVideo;Player;Video;
MimeType=video/x-msvideo;video/x-matroska;video/webm;video/mpeg;video/mp4;
Terminal=false
StartupNotify=true
Exec=$PRODUCT %f
Icon=svp-manager4.png
EOF

add_requires mpv libqt5-concurrent
add_unirequires libPythonQt.so.0 "python3(vapoursynth)" libmediainfo.so.0
ignore_lib_requires libPythonQt.so.1 libPythonQt.so.3 libnvinfer.so.10
add_libs_requires
add_bin_link_command $PRODUCT $PRODUCTDIR/SVPManager
