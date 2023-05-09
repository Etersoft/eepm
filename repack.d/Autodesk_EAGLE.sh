#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=eagle
PRODUCTDIR=/opt/$PRODUCT

INSTALL_PACKAGES="coreutils fontconfig glib2 libalsa libcom_err libcups libdrm libexpat libfreetype libGL libkeyutils libkrb5 libnspr libnss libX11 libxcb libXrandr zlib"

. $(dirname $0)/common.sh

#subst '1iAutoProv:no' $SPEC

# move package to /opt
ROOTDIR=$(basename $(find $BUILDROOT -mindepth 1 -maxdepth 1 -type d))
subst "s|^License: unknown$|License: Freeware|" $SPEC
subst "s|^Summary:.*|Summary: EAGLE is electronic design automation (EDA) software that lets printed circuit board (PCB)|" $SPEC

mkdir $BUILDROOT/opt
mv $BUILDROOT/$ROOTDIR $BUILDROOT/opt/$PRODUCT
subst "s|\"/$ROOTDIR/|\"/opt/$PRODUCT/|" $SPEC

add_bin_link_command

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=EAGLE
Comment=PCB design: schematic capture, board layout, and autorouter

# paths need to be absolute, no ~ allowed within this file
Exec=$PRODUCT
Icon=$PRODUCT

# meta data 
Categories=Engineering;Electronics;
Keywords=eagle;pcb;schematics;electronics;
MimeType=application/x-eagle-schematic;application/x-eagle-board;application/x-eagle-project;

# used to group all windows under the same launcher icon
StartupWMClass=eagle
EOF
pack_file /usr/share/applications/$PRODUCT.desktop
install_file /opt/eagle/bin/eagle-logo.png /usr/share/pixmaps/$PRODUCT.png

# https://bugzilla.altlinux.org/44898
remove_file /opt/eagle/lib/libxcb-dri2.so.0
remove_file /opt/eagle/lib/libxcb-dri3.so.0


if epm assure patchelf ; then
    for i in $BUILDROOT/$PRODUCTDIR/lib/{libssl.so,libssl.so.1.*} ; do
        a= patchelf --set-rpath '$ORIGIN/' $i
    done
fi
