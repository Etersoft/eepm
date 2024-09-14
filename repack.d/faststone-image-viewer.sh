#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=faststone-image-viewer
PRODUCTDIR=/opt/eepm-wine/$PRODUCT

. $(dirname $0)/common.sh

add_requires '/usr/bin/wine'

add_bin_link_command $PRODUCT $PRODUCTDIR/run.sh

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=Faststone image viewer
Exec=$PRODUCT %F
Type=Application
StartupNotify=true
Icon=$PRODUCT
StartupWMClass=FSViewer.exe
Categories=Wine;Graphics;
EOF

# copied from unpacked exe file: FSViewer.exe
i=128
install_file ipfs://QmTQMybWanVQBrV5diGrKDnMbU3zWXtG26uTJ8bcjcKKMp /usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCT.png
