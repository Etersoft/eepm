#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=yandex-messenger

. $(dirname $0)/common.sh

add_conflicts chats

add_requires '/usr/bin/wine'

add_bin_link_command $PRODUCT $PRODUCTDIR/run.sh

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Yandex Messenger
Comment=Yandex Messenger (Wine)
Exec=$PRODUCT
Icon=$PRODUCT
Terminal=false
Categories=Network;InstantMessaging;
EOF

# TODO: add icon to IPFS
#install_file "ipfs://HASH" /usr/share/pixmaps/$PRODUCT.png
