#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

mkdir -p usr/bin
cp -L $TAR usr/bin/wiimplay
chmod 755 usr/bin/wiimplay

mkdir -p usr/share/applications
cat <<'EOF' | create_file /usr/share/applications/wiimplay.desktop
[Desktop Entry]
Type=Application
Name=WiiM Play
Comment=UPnP control point for WiiM music streamers
Exec=wiimplay
Icon=wiimplay
Terminal=false
Categories=Audio;Player;GTK;
EOF

erc pack $PKGNAME.tar usr

return_tar $PKGNAME.tar
