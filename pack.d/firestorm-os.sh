#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc -C opt/$PRODUCT unpack $TAR || fatal

VERSION=$(echo "$TAR" | grep -oP '(?<=Releasex64-)\d+-\d+-\d+-\d+' | tr '-' '.')
[ -n "$VERSION" ] || fatal "Can't get package version"

install_file opt/firestorm-os/firestorm_icon.png /usr/share/pixmaps/$PRODUCT.png

# create desktop file
cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Firestorm Open Simulator viewer
Comment=OpenSimulator is an application server. It can be used to create a virtual environment
Exec=$PRODUCT %U
Icon=$PRODUCT
Terminal=false
Categories=Game
EOF

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Games/Other
license: LGPL-2.1
url: https://www.firestormviewer.org/
summary: Firestorm OpenSimulator viewer
description: Firestorm is an alternative viewer for OpenSimulator virtual worlds.
EOF

return_tar $PKGNAME.tar
