#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Telegram
PRODUCTCUR=telegram-desktop
PRODUCTDIR=/opt/Telegram

. $(dirname $0)/common.sh

# /usr/bin/Telegram
subst '1iConflicts:telegram-desktop' $SPEC
subst '1iConflicts:telegram-desktop-binary' $SPEC

subst "s|^Group:.*|Group: Networking/Instant messaging|" $SPEC
subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://desktop.telegram.org/|" $SPEC
subst "s|^Summary:.*|Summary: Telegram Desktop messaging app|" $SPEC


# move package to /opt
ROOTDIR=$(basename $(find $BUILDROOT -mindepth 1 -maxdepth 1 -type d))
mkdir $BUILDROOT/opt
mv $BUILDROOT/$ROOTDIR $BUILDROOT$PRODUCTDIR
subst "s|\"/$ROOTDIR/|\"$PRODUCTDIR/|" $SPEC

# add binary to the search path
mkdir -p $BUILDROOT/usr/bin/
ln -s $PRODUCTDIR/Telegram $BUILDROOT/usr/bin/$PRODUCT
subst "s|%files|%files\n/usr/bin/$PRODUCT|" $SPEC
ln -s $PRODUCTDIR/Telegram $BUILDROOT/usr/bin/$PRODUCTCUR
subst "s|%files|%files\n/usr/bin/$PRODUCTCUR|" $SPEC

# Icons
iconname=$PRODUCT
url=https://github.com/telegramdesktop/tdesktop
for i in 16 32 48 64 128 256 512 ; do
    mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
    epm tool eget -O $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png $url/raw/master/Telegram/Resources/art/icon$i.png || continue
    pack_file /usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done


# Disable the official Telegram Desktop updater
mkdir -p "$BUILDROOT/etc/tdesktop"
echo "$PRODUCTCUR" >"$BUILDROOT/etc/tdesktop/externalupdater"
pack_file /etc/tdesktop/externalupdater
remove_file /opt/Telegram/Updater

# Hack against https://bugzilla.altlinux.org/42402
# We can't forbit creating a desktop file, so just hide it
subst "s|Terminal=false|NoDisplay=true|" $BUILDROOT$PRODUCTDIR/Telegram

# TODO: tg.protocol
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=telegram-desktop-bin

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=Telegram Desktop
Comment=Official desktop version of Telegram messaging app
TryExec=$PRODUCTDIR/Telegram
Exec=$PRODUCTDIR/Telegram -- %u
Icon=$PRODUCT
Terminal=false
StartupWMClass=TelegramDesktop
Type=Application
Categories=Chat;Network;InstantMessaging;Qt;
MimeType=x-scheme-handler/tg;
Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
X-GNOME-UsesNotifications=true
EOF
subst "s|%files|%files\n/usr/share/applications/$PRODUCT.desktop|" $SPEC
