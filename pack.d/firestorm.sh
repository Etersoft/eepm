#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc unpack $TAR || fatal

mkdir -p opt
mv Phoenix-Firestorm-Releasex64-* $PRODUCT
mv $PRODUCT opt/

VERSION=$(echo "$TAR" | grep -oP '(?<=Releasex64-)\d+-\d+-\d+-\d+' | tr '-' '.')
[ -n "$VERSION" ] || fatal "Can't get package version"

install_file opt/firestorm/firestorm_icon.png /usr/share/pixmaps/$PRODUCT.png

# create desktop file
cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Firestorm Second Life viewer
Comment=Second Life is a 3-D virtual world entirely built and owned by its residents
Exec=$PRODUCT %U
Icon=$PRODUCT
Terminal=false
Categories=Game
EOF

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
