#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

VERSION=$(echo "$URL" | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+')
[ -n "$VERSION" ] || fatal "Can't get package version"
PKGNAME=$PRODUCT-$VERSION

erc -C opt/$PRODUCT unpack $TAR || fatal
chmod 0755 opt/$PRODUCT/$PRODUCT

iconname=chat.fluffy.$PRODUCT
install_file opt/$PRODUCT/data/flutter_assets/assets/favicon.png /usr/share/pixmaps/$iconname.png

cat <<EOF | create_file /usr/share/applications/$iconname.desktop
[Desktop Entry]
Version=1.0
Name=FluffyChat
Comment=Open source Matrix messenger
Exec=$PRODUCT %u
Icon=$iconname
StartupWMClass=fluffychat
Type=Application
Categories=Chat;Network;InstantMessaging;
MimeType=x-scheme-handler/matrix;
Keywords=matrix;chat;im;messaging;messenger;
EOF

erc pack $PKGNAME.tar opt usr

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Instant messaging
license: AGPLv3
url: https://github.com/krille-chan/fluffychat
summary: Open source Matrix messenger
description: FluffyChat is an open source, nonprofit and cute Matrix messenger.
EOF

return_tar $PKGNAME.tar
