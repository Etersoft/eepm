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
subst '1iConflicts:telegram-desktop' $SPEC
subst '1iConflicts:telegram-desktop-binary' $SPEC

for i in Telegram Telegram-beta ; do
    [ "$i"  = "$PKGNAME" ] && continue
    subst "1iConflicts:$i" $SPEC
done

# installing from tar, so we need fill some fields here
subst "s|^Group:.*|Group: Networking/Instant messaging|" $SPEC
subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://desktop.telegram.org/|" $SPEC
subst "s|^Summary:.*|Summary: Telegram Desktop messaging app|" $SPEC

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

# Icons
iconname=$PRODUCT
url=https://github.com/telegramdesktop/tdesktop
for i in 16 32 48 64 128 256 512 ; do
    mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
    epm tool eget -O $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png $url/raw/master/Telegram/Resources/art/icon$i.png || continue
    pack_file /usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done


# Disable the official Telegram Desktop updater, creating menu entry (desktop file) and settings entries
# See https://github.com/telegramdesktop/tdesktop/issues/25718

# New way:
# commit 2be4641496f6f5efc7c18c2842ad00ddf51be43c
#Author: Ilya Fedin <fedin-ilja2010@ya.ru>
#Date:   Fri Jan 13 17:58:36 2023 +0400
#
#    Install launcher on every launch on Linux
# set DESKTOPINTEGRATION or disable update via set path to binary to /etc/tdesktop/externalupdater

mkdir -p "$BUILDROOT/etc/tdesktop"
# telegram checks with real path to the binary
echo "$PRODUCTDIR/$PRODUCT" >"$BUILDROOT/etc/tdesktop/externalupdater"
pack_dir /etc/tdesktop
pack_file /etc/tdesktop/externalupdater
#remove_file /opt/Telegram/Updater

# fixed above
# Hack against https://bugzilla.altlinux.org/42402
# We can't forbit creating a desktop file, so just hide it
#subst "s|Terminal=false|NoDisplay=true|" $BUILDROOT$PRODUCTDIR/Telegram

# TODO: tg.protocol
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=telegram-desktop-bin

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/org.telegram.desktop
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
pack_file /usr/share/applications/org.telegram.desktop

add_by_ldd_deps
