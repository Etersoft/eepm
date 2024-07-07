#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME="$(basename $TAR | awk '{print tolower($0)}')"
mkdir -p opt/$PRODUCT
mv $TAR opt/$PRODUCT/ || fatal
mv opt/$PRODUCT/$(basename $TAR) opt/$PRODUCT/$PRODUCT
chmod 0755 opt/$PRODUCT/$PRODUCT

#IPFS_ICONS_URL="ipfs://QmWYv5mMrvpbN9YWpJ2MuK9rEu6crJBP8YvDp1SKxhqLWP?filename=telegram-icons.tar"
#if eget $IPFS_ICONS_URL && erc telegram-icons.tar ; then
#    iconpath=telegram-icons
#else
iconpath=https://github.com/AyuGram/AyuGramDesktop/raw/dev/Telegram/Resources/art
#fi

iconname=$PRODUCT
for i in 16 32 48 64 128 256 512 ; do
    install_file $iconpath/icon$i.png /usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done

cat <<EOF | create_file /usr/share/applications/ayugram.desktop.desktop
[Desktop Entry]
Version=1.0
Name=AyuGram Desktop
Comment=Desktop Telegram client with good customization and Ghost mode
Exec=$PRODUCT -- %u
Icon=$iconname
StartupWMClass=AyuGram
Type=Application
Categories=Chat;Network;InstantMessaging;Qt;
MimeType=x-scheme-handler/tg;
Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
X-GNOME-UsesNotifications=true
EOF

erc pack $PKGNAME.tar opt usr

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Instant messaging
license: GPLv3
url: https://github.com/AyuGram/AyuGramDesktop
summary: Unofficial Telegram Client
description: Unofficial Telegram Client
EOF

return_tar $PKGNAME.tar
