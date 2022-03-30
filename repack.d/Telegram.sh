#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Telegram
PRODUCTOPT=telegram-desktop

# /usr/bin/Telegram
subst '1iConflicts:telegram-desktop < 3.2.8' $SPEC

subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://desktop.telegram.org/|" $SPEC
subst "s|^Summary:.*|Summary: Telegram Desktop messaging app|" $SPEC


# move package to /opt
ROOTDIR=$(basename $(find $BUILDROOT -mindepth 1 -maxdepth 1 -type d))
mkdir $BUILDROOT/opt
mv $BUILDROOT/$ROOTDIR $BUILDROOT/opt/$PRODUCT
subst "s|\"/$ROOTDIR/|\"/opt/$PRODUCT/|" $SPEC

# add binary to the search path
mkdir -p $BUILDROOT/usr/bin/
ln -s /opt/$PRODUCT/Telegram $BUILDROOT/usr/bin/$PRODUCT
subst "s|%files|%files\n/usr/bin/$PRODUCT|" $SPEC
ln -s /opt/$PRODUCT/Telegram $BUILDROOT/usr/bin/$PRODUCTOPT
subst "s|%files|%files\n/usr/bin/$PRODUCTOPT|" $SPEC

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=Telegram Desktop
Comment=Official desktop version of Telegram messaging app
TryExec=/opt/$PRODUCT/Telegram
Exec=/opt/$PRODUCT/Telegram -- %u
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
