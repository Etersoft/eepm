#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc unpack $TAR || fatal

mkdir -p opt
mv Phoenix-FirestormOS-Releasex64-* $PRODUCT
mv $PRODUCT opt/

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

return_tar $PKGNAME.tar
