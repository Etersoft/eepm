#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

if [ -f $BUILDROOT/opt/nekoray/nekoray ]; then
	PRODUCT=nekoray
else
	PRODUCT=nekobox
fi

PRODUCTDIR=/opt/nekoray

. $(dirname $0)/common.sh

add_bin_link_command

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=Nekoray
Comment=Qt based cross-platform GUI proxy configuration manager (backend: Xray / sing-box)
Exec=$PRODUCT -- %u -appdata
Icon=$PRODUCT
Type=Application
Terminal=false
Categories=Network;Internet;Utility;
EOF

install_file $PRODUCTDIR/$PRODUCT.png /usr/share/pixmaps/$PRODUCT.png

add_libs_requires
