#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=yandex-telemost
PRODUCTDIR=/opt/eepm-wine/$PRODUCT

. $(dirname $0)/common.sh

add_requires '/usr/bin/wine'

add_bin_link_command $PRODUCT $PRODUCTDIR/run.sh

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=Yandex Telemost
Exec=$PRODUCT %F
Type=Application
StartupNotify=true
Icon=$PRODUCT
StartupWMClass=YandexTelemost.exe
Categories=Wine;Chat;Network;InstantMessaging;
EOF

# copied from unpacked exe file: Telemost.exe
i=256
install_file ipfs://QmXkZQuL8CrJDvNSSAGk7uYro12zkaaRuddCrxsK5EPXHu /usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCT.png
