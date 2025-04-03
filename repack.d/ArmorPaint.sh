#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Graphics|" $SPEC
subst "s|^License: unknown$|License: zlib/libpng|" $SPEC
subst "s|^URL:.*|URL: https://armorpaint.org|" $SPEC
subst "s|^Summary:.*|Summary: 3D PBR texture painting software|" $SPEC

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=$PRODUCT
Comment=3D PBR texture painting software
Exec=$PRODUCT %f
Icon=$PRODUCT
Terminal=false
StartupNotify=true
Categories=Engineering;
EOF

install_file ipfs://QmUvB4BvoUsQDxMUH9rZ3PMaZgYoBishLyGBwxdDQ1uHcU /usr/share/pixmaps/$PRODUCT.png

add_bin_exec_command
#add_bin_link_command $PRODUCTCUR $PRODUCT

add_libs_requires
