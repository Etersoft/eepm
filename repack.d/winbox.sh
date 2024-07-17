#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=winbox
PRODUCTDIR=/opt/eepm-wine/$PRODUCT

. $(dirname $0)/common.sh

add_requires '/usr/bin/wine'

add_bin_link_command $PRODUCT $PRODUCTDIR/run.sh

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=WinBox
Exec=$PRODUCT %F
Type=Application
StartupNotify=true
Icon=$PRODUCT
StartupWMClass=winbox64.exe
Categories=Wine;Network;
EOF

# copied from unpacked exe file: winbox64.exe
i=48
install_file ipfs://Qmdkgx2mstbxHtvFuooaUTrRL1tnz5XWh5seiyXQGkTmCW /usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCT.png
