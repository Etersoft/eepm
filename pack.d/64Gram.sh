#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
FPRODUCT="Telegram"

. $(dirname $0)/common.sh

erc $TAR || fatal

# use version from tarball
# (TODO: get basename via erc
PKGNAME="$(basename $TAR .zip | sed -e "s|_linux||" )"

f=$FPRODUCT
[ -f "$(echo */$FPRODUCT)" ] && f="$(echo */$FPRODUCT)"

install -D -m755 $f opt/$PRODUCT/$PRODUCT || fatal

# Icons
iconname=$PRODUCT
url=https://github.com/TDesktop-x64/tdesktop
for i in 16 32 48 64 128 256 512 ; do
    install_file $url/raw/master/Telegram/Resources/art/icon$i.png /usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done


cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=64Gram
Comment=64Gram (unofficial Telegram Desktop)
Exec=$PRODUCT -- %u
Icon=$iconname
StartupWMClass=64Gram
Type=Application
Categories=Chat;Network;InstantMessaging;Qt;
MimeType=x-scheme-handler/tg;
Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
X-GNOME-UsesNotifications=true
EOF


erc pack $PKGNAME.tar opt/$PRODUCT usr

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Instant messaging
license: GPLv2
url: https://github.com/TDesktop-x64/tdesktop
summary: 64Gram (unofficial Telegram Desktop)
description: 64Gram (unofficial Telegram Desktop).
EOF

return_tar $PKGNAME.tar
