#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=64Gram
PRODUCTCUR=64gram
PKGNAME=$(basename $0 .sh)
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# installing from tar, so we need fill some fields here
subst "s|^Group:.*|Group: Networking/Instant messaging|" $SPEC
subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://github.com/TDesktop-x64/tdesktop|" $SPEC
subst "s|^Summary:.*|Summary: 64Gram (unofficial Telegram Desktop)|" $SPEC

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

# Icons
iconname=$PRODUCT
url=https://github.com/TDesktop-x64/tdesktop
for i in 16 32 48 64 128 256 512 ; do
    mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
    epm tool eget -O $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png $url/raw/master/Telegram/Resources/art/icon$i.png || continue
    pack_file /usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done


# away of file conflict
subst 's|/etc/tdesktop/externalupdater|/etc/t64gramp/externalupdater|' $BUILDROOT$PRODUCTDIR/$PRODUCT
# since newest versions telegram uses UCS2
# $ echo -n '/etc/tdesktop/externalupdater' | iconv -t UCS2 | hexdump -ve '1/1 " %02x"' | sed -e 's| |\\x|g'
# $ echo -n '/etc/t64gramp/externalupdater' | iconv -t UCS2 | hexdump -ve '1/1 " %02x"' | sed -e 's| |\\x|g'
subst 's|\x2f\x00\x65\x00\x74\x00\x63\x00\x2f\x00\x74\x00\x64\x00\x65\x00\x73\x00\x6b\x00\x74\x00\x6f\x00\x70\x00\x2f\x00\x65\x00\x78\x00\x74\x00\x65\x00\x72\x00\x6e\x00\x61\x00\x6c\x00\x75\x00\x70\x00\x64\x00\x61\x00\x74\x00\x65\x00\x72\x00|\x2f\x00\x65\x00\x74\x00\x63\x00\x2f\x00\x74\x00\x36\x00\x34\x00\x67\x00\x72\x00\x61\x00\x6d\x00\x70\x00\x2f\x00\x65\x00\x78\x00\x74\x00\x65\x00\x72\x00\x6e\x00\x61\x00\x6c\x00\x75\x00\x70\x00\x64\x00\x61\x00\x74\x00\x65\x00\x72\x00|' $BUILDROOT$PRODUCTDIR/$PRODUCT

# Disable the official Telegram Desktop updater, creating menu entry (desktop file) and settings entries
# See https://github.com/telegramdesktop/tdesktop/issues/25718

# New way:
# commit 2be4641496f6f5efc7c18c2842ad00ddf51be43c
#Author: Ilya Fedin <fedin-ilja2010@ya.ru>
#Date:   Fri Jan 13 17:58:36 2023 +0400
#
#    Install launcher on every launch on Linux
# set DESKTOPINTEGRATION or disable update via set path to binary to /etc/t64gramp/externalupdater

mkdir -p "$BUILDROOT/etc/t64gramp"
# telegram checks with real path to the binary
echo "$PRODUCTDIR/$PRODUCT" >"$BUILDROOT/etc/t64gramp/externalupdater"
pack_dir /etc/t64gramp
pack_file /etc/t64gramp/externalupdater
#remove_file $PRODUCTDIR/Updater

# fixed above
# Hack against https://bugzilla.altlinux.org/42402
# We can't forbit creating a desktop file, so just hide it
#subst "s|Terminal=false|NoDisplay=true|" $BUILDROOT$PRODUCTDIR/Telegram

# TODO: tg.protocol
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=telegram-desktop-bin

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=64Gram
Comment=64Gram (unofficial Telegram Desktop)
Exec=$PRODUCTCUR -- %u
Icon=$iconname
StartupWMClass=64Gram
Type=Application
Categories=Chat;Network;InstantMessaging;Qt;
MimeType=x-scheme-handler/tg;
Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
X-GNOME-UsesNotifications=true
EOF
pack_file /usr/share/applications/$PRODUCT.desktop
