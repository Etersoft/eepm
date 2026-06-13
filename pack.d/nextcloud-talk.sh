#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
PKGURL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$PKGURL" | sed -n 's|.*/download/v\([0-9][0-9.]*\)/.*|\1|p')"
[ -n "$VERSION" ] || fatal "Can't get package version"
PKGNAME=$PRODUCT-$VERSION

erc -C opt/$PRODUCT unpack "$TAR" || fatal

install_file https://github.com/nextcloud/talk-desktop/raw/refs/heads/main/img/talk-icon-rounded-spaced.svg /usr/share/icons/hicolor/scalable/apps/$PRODUCT.svg

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=Nextcloud Talk
Comment=Nextcloud Talk desktop client
Exec=$PRODUCT %u
Icon=$PRODUCT
Type=Application
Categories=Chat;Network;InstantMessaging;
MimeType=x-scheme-handler/nextcloud-talk;
Keywords=nextcloud;talk;chat;call;video;messaging;messenger;
EOF

erc pack "$PKGNAME.tar" opt usr || fatal

cat <<EOF >"$PKGNAME.tar.eepm.yaml"
name: $PRODUCT
version: $VERSION
group: Networking/Instant messaging
license: AGPL-3.0
url: https://github.com/nextcloud-releases/talk-desktop
summary: Nextcloud Talk desktop client
description: Nextcloud Talk is a desktop client for Nextcloud Talk.
EOF

return_tar "$PKGNAME.tar"
