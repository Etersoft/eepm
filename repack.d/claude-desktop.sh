#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=claude-desktop
PRODUCTDIR=/opt/eepm-wine/$PRODUCT

. $(dirname $0)/common.sh

add_requires '/usr/bin/wine'

add_bin_link_command $PRODUCT $PRODUCTDIR/run.sh

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=Claude Desktop
Exec=$PRODUCT %u
Type=Application
StartupNotify=true
Icon=$PRODUCT
StartupWMClass=claude.exe
Categories=Wine;Network;InstantMessaging;
MimeType=x-scheme-handler/claude;
EOF

# copied from .local/share/icons/hicolor/256x256/apps/84BD_claude.0.png
i=256
install_file ipfs://QmbnRtSF3e5dENA6TGKADxpzNXMF5vV1UDaRGrKsQXu4xZ /usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCT.png
