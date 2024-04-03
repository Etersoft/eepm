#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

erc unpack $TAR
cd * || fatal

mkdir -p usr/bin/
mv flashplayer usr/bin/
mkdir -p usr/share/doc/flashplayer/
mv LGPL license.pdf usr/share/doc/flashplayer/

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Adobe Flash Player Standalone
Comment=Player for using content created on the Adobe Flash platform
Icon=$PRODUCT
Exec=$PRODUCT %u
Categories=Audio;AudioVideo;Graphics;GTK;Player;Video;Viewer;
MimeType=application/x-shockwave-flash;
Terminal=false
EOF

# from https://logos.fandom.com/wiki/Adobe_Flash_Player#2015%E2%80%932020
# https://static.wikia.nocookie.net/logopedia/images/7/7c/Flashplayer_app_RGB.svg/revision/latest/scale-to-width-down/200?cb=20190707103515
install_file "https://static.wikia.nocookie.net/logopedia/images/7/7c/Flashplayer_app_RGB.svg/revision/latest/scale-to-width-down/200?cb=20190707103515" /usr/share/icons/hicolor/scalable/apps/$PRODUCT.svg

erc pack $PKGNAME.tar usr

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/WWW
license: Multiple, see https://brave.com/
url: https://www.adobe.com/support/flashplayer/downloads.html
summary: Adobe Flash Player Standalone
description: Adobe Flash Player Standalone.
EOF


return_tar $PKGNAME.tar
