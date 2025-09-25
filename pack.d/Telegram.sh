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

IPFS_ICONS_URL="ipfs://QmNV53KfivD8FDMAVVpErNyPrugckgkvGQMRimpNz25Swn?filename=telegram-icons.tar"
if eget $IPFS_ICONS_URL && erc telegram-icons.tar ; then
    iconpath=telegram-icons
else
    iconpath=https://github.com/telegramdesktop/tdesktop/raw/master/Telegram/Resources/art
    trayiconpath=https://github.com/telegramdesktop/tdesktop/raw/master/Telegram/Resources/icons
fi

desktopname=org.telegram.desktop
# GNOME ignores Icon= and use desktop name for icon
iconname=$desktopname

for i in 16 32 48 64 128 256 512 ; do
    install_file $iconpath/icon$i.png /usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done

if [ -n "$trayiconpath" ] ; then
    install_file $trayiconpath/tray_monochrome.svg /usr/share/icons/hicolor/symbolic/apps/org.telegram.desktop-symbolic.svg
    install_file $trayiconpath/tray_monochrome_attention.svg /usr/share/icons/hicolor/symbolic/apps/org.telegram.desktop-attention-symbolic.svg
    install_file $trayiconpath/tray_monochrome_mute.svg /usr/share/icons/hicolor/symbolic/apps/org.telegram.desktop-mute-symbolic.svg
else
    for i in org.telegram.desktop-attention-symbolic.svg org.telegram.desktop-mute-symbolic.svg org.telegram.desktop-symbolic.svg ; do
        install_file $iconpath/$i /usr/share/icons/hicolor/symbolic/apps/$i
    done
fi

cat <<EOF | create_file /usr/share/applications/$desktopname.desktop
[Desktop Entry]
Version=1.0
Name=Telegram Desktop
Comment=Official desktop version of Telegram messaging app
Exec=$PRODUCT -- %u
Icon=$iconname
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
