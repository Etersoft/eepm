#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc --here unpack $TAR || fatal

install -D -m755 Telega opt/$PRODUCT/$PRODUCT || fatal

IPFS_ICONS_URL="ipfs://QmdC3jcHAiZxLL9u9jggcyjmbLSXHCAvrR1YrKfNCX3aDX?filename=telega-icons.tar"
if eget $IPFS_ICONS_URL && erc telega-icons.tar ; then
    iconpath=telega-icons
else
    iconpath=https://raw.githubusercontent.com/Telegru/tdesktop/dev/Telegram/Resources/art
fi

desktopname=me.telega.desktop
iconname=$desktopname

for i in 16 32 48 64 128 256 512 ; do
    install_file $iconpath/icon$i.png /usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done

cat <<EOF | create_file /usr/share/applications/$desktopname.desktop
[Desktop Entry]
Version=1.0
Name=Telega
Comment=Telega messenger
Exec=$PRODUCT -- %u
Icon=$iconname
Type=Application
Categories=Chat;Network;InstantMessaging;Qt;
MimeType=x-scheme-handler/tg;
Keywords=tg;chat;im;messaging;messenger;telega;
X-GNOME-UsesNotifications=true
EOF

VERSION="$(echo "$TAR" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
[ -n "$VERSION" ] || VERSION="0"
PKGNAME="$PRODUCT-$VERSION"

erc pack $PKGNAME.tar opt/$PRODUCT usr

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Instant messaging
license: GPLv2
url: https://telega.me
summary: Telega messenger
description: Telega messenger (fork of Telegram Desktop).
EOF

return_tar $PKGNAME.tar
