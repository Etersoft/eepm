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

# move package to /opt
ROOTDIR=$(basename $(find $BUILDROOT -mindepth 1 -maxdepth 1 -type d) 2>/dev/null)
if [ -n "$ROOTDIR" ] ; then
    mkdir -p $BUILDROOT/opt/
    mv $BUILDROOT/$ROOTDIR $BUILDROOT$PRODUCTDIR
    subst "s|\"/$ROOTDIR/|\"$PRODUCTDIR/|" $SPEC
else
    mkdir -p $BUILDROOT$PRODUCTDIR/
    mv $BUILDROOT/* $BUILDROOT$PRODUCTDIR/
    subst "s|^\"/|\"$PRODUCTDIR/|" $SPEC
fi

move_file $PRODUCTDIR/Telegram $PRODUCTDIR/$PRODUCT

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

# Disable the official Telegram Desktop updater, creating menu entry (desktop file) and settings entries
# See https://github.com/telegramdesktop/tdesktop/issues/25718
mkdir -p "$BUILDROOT/etc/t64gramp"
# telegram checks with real path to the binary
echo "$PRODUCTDIR/$PRODUCT" >"$BUILDROOT/etc/t64gramp/externalupdater"
pack_file /etc/t64gramp/externalupdater
remove_file $PRODUCTDIR/Updater

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
