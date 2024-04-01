#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=64Gram
PRODUCTCUR=64gram
PKGNAME=$(basename $0 .sh)
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

# Icons
iconname=$PRODUCT
url=https://github.com/TDesktop-x64/tdesktop
for i in 16 32 48 64 128 256 512 ; do
    install_file $url/raw/master/Telegram/Resources/art/icon$i.png /usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done

echo "$PRODUCTDIR/$PRODUCT" | create_file /usr/share/64Gram/externalupdater.d/telegram-desktop.conf

# TODO: tg.protocol
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=telegram-desktop-bin

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

add_libs_requires