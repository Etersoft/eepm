#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
FPRODUCT="Telegram"
TPRODUCT="Telegram"

. $(dirname $0)/common.sh

erc $TAR || fatal

# use version from tarball
# (TODO: get basename via erc
PKGNAME="$(basename $TAR .tar.xz | sed -e "s|^tsetup|$PRODUCT|" )"
#PKGNAME="$(basename $PKGNAME .zip | )"

f=$FPRODUCT
[ -f "$(echo */$FPRODUCT)" ] && f="$(echo */$FPRODUCT)"

install -D -m755 $f opt/$TPRODUCT/$TPRODUCT || fatal

# TODO: move to ipfs
# Icons
iconname=$PRODUCT
url=https://github.com/telegramdesktop/tdesktop
for i in 16 32 48 64 128 256 512 ; do
    install_file $url/raw/master/Telegram/Resources/art/icon$i.png /usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done

cat <<EOF | create_file /usr/share/applications/org.telegram.desktop.desktop
[Desktop Entry]
Version=1.0
Name=Telegram Desktop
Comment=Official desktop version of Telegram messaging app
Exec=$PRODUCT -- %u
Icon=$iconname
StartupWMClass=TelegramDesktop
Type=Application
Categories=Chat;Network;InstantMessaging;Qt;
MimeType=x-scheme-handler/tg;
Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
X-GNOME-UsesNotifications=true
EOF

erc pack $PKGNAME.tar opt/$TPRODUCT usr

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Instant messaging
license: GPLv2
url: https://desktop.telegram.org/
summary: Telegram Desktop messaging app
description: Telegram Desktop messaging app.
EOF

return_tar $PKGNAME.tar
