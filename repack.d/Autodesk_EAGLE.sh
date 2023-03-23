#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=eagle
PRODUCTDIR=/opt/$PRODUCT

#subst '1iAutoProv:no' $SPEC

# move package to /opt
ROOTDIR=$(basename $(find $BUILDROOT -mindepth 1 -maxdepth 1 -type d))
subst "s|^License: unknown$|License: Freeware|" $SPEC
subst "s|^Summary:.*|Summary: EAGLE is electronic design automation (EDA) software that lets printed circuit board (PCB)|" $SPEC

mkdir $BUILDROOT/opt
mv $BUILDROOT/$ROOTDIR $BUILDROOT/opt/$PRODUCT
subst "s|\"/$ROOTDIR/|\"/opt/$PRODUCT/|" $SPEC

# add binary in standart path
mkdir -p $BUILDROOT/usr/bin/
ln -s /opt/$PRODUCT/eagle $BUILDROOT/usr/bin/$PRODUCT
subst "s|%files|%files\n/usr/bin/$PRODUCT|" $SPEC

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
Exec=/usr/bin/eagle
Icon=/opt/eagle/bin/eagle-logo.png

# meta data 
Categories=Engineering;Electronics;
Keywords=eagle;pcb;schematics;electronics;
MimeType=application/x-eagle-schematic;application/x-eagle-board;application/x-eagle-project;

# used to group all windows under the same launcher icon
StartupWMClass=eagle
EOF
subst "s|%files|%files\n/usr/share/applications/$PRODUCT.desktop|" $SPEC


# https://bugzilla.altlinux.org/44898
remove_file /opt/eagle/lib/libxcb-dri2.so.0
remove_file /opt/eagle/lib/libxcb-dri3.so.0


epm assure patchelf || exit
for i in $BUILDROOT/$PRODUCTDIR/lib/{libssl.so,libssl.so.1.*} ; do
    a= patchelf --set-rpath '$ORIGIN/' $i
done

epm install --skip-installed coreutils fontconfig glib2 libalsa libcom_err libcups libdrm libexpat libfreetype libGL libkeyutils libkrb5 libnspr libnss libX11 libxcb libXrandr zlib
