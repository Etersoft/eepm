#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=eagle
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_bin_link_command

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
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

install_file /opt/eagle/bin/eagle-logo.png /usr/share/pixmaps/$PRODUCT.png

# https://bugzilla.altlinux.org/44898
remove_file /opt/eagle/lib/libxcb-dri2.so.0
remove_file /opt/eagle/lib/libxcb-dri3.so.0

