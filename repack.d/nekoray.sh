#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=nekoray
PRODUCTDIR=/opt/nekoray

. $(dirname $0)/common.sh

add_bin_link_command

add_libs_requires

cat <<EOF |create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=Nekoray
Comment=Qt based cross-platform GUI proxy configuration manager (backend: Xray / sing-box)
Exec=$PRODUCT -- %u -appdata
Icon=/opt/nekoray/nekoray.png
Type=Application
Terminal=false
Categories=Network;
EOF
