#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=eagle

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
