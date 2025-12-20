#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"
PRODUCT=v2rayN
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_bin_link_command

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=v2rayN
Comment=A GUI client for Windows, Linux and macOS, support Xray core and sing-box-core and others
Exec=$PRODUCT %f
Icon=$PRODUCT
Type=Application
Terminal=false
Categories=Network;Internet;Utility;
EOF

install_file $PRODUCTDIR/$PRODUCT.png /usr/share/pixmaps/$PRODUCT.png

