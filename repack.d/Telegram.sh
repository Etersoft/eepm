#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Telegram
PRODUCTCUR=telegram-desktop
PKGNAME=$(basename $0 .sh)
PRODUCTDIR=/opt/Telegram

. $(dirname $0)/common.sh

# /usr/bin/Telegram
add_conflicts telegram-desktop
add_conflicts telegram-desktop-binary

for i in Telegram Telegram-beta ; do
    [ "$i"  = "$PKGNAME" ] && continue
    add_conflicts $i
done

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

# Icons
iconname=$PRODUCT
url=https://github.com/telegramdesktop/tdesktop
for i in 16 32 48 64 128 256 512 ; do
    install_file $url/raw/master/Telegram/Resources/art/icon$i.png /usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done


echo "$PRODUCTDIR/$PRODUCT" | create_file /usr/share/TelegramDesktop/externalupdater.d/telegram-desktop.conf

# TODO: tg.protocol
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=telegram-desktop-bin

cat <<EOF | create_file /usr/share/applications/org.telegram.desktop.desktop
[Desktop Entry]
Version=1.0
Name=Telegram Desktop
Comment=Official desktop version of Telegram messaging app
Exec=$PRODUCTCUR -- %u
Icon=$iconname
StartupWMClass=TelegramDesktop
Type=Application
Categories=Chat;Network;InstantMessaging;Qt;
MimeType=x-scheme-handler/tg;
Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
X-GNOME-UsesNotifications=true
EOF

add_libs_requires
