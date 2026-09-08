#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] && [ "$VERSION" != "*" ] || \
    VERSION="$(echo "$URL" | sed -n 's|.*/download/v\([^/]*\)/.*|\1|p')"
[ -n "$VERSION" ] || fatal "Can't get package version"
# RPM version fields do not allow hyphens; retain prerelease ordering with ~.
VERSION="$(echo "$VERSION" | sed 's/-/~/')"

PKGNAME=$PRODUCT-$VERSION

erc -C opt/$PRODUCT unpack "$TAR" || fatal

install_file opt/$PRODUCT/data/flutter_assets/assets/komet_icon.png /usr/share/pixmaps/$PRODUCT.png

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Type=Application
Name=Komet
Comment=Alternative MAX client with privacy and customization controls
Comment[ru]=Альтернативный клиент MAX с расширенными настройками и акцентом на приватность
Exec=$PRODUCT %U
Icon=$PRODUCT
Terminal=false
StartupWMClass=Komet
Categories=Chat;Network;InstantMessaging;
MimeType=x-scheme-handler/max;
Keywords=max;chat;im;messaging;messenger;privacy;
EOF

erc pack $PKGNAME.tar opt usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Networking/Instant messaging
license: GPL-3.0-only
url: https://github.com/KometTeam/Komet
summary: Alternative MAX client
description: Komet is a multifunctional MAX client written in Dart with enhanced privacy and customization options.
EOF

return_tar $PKGNAME.tar
