#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
URL="$4"

. $(dirname $0)/common.sh

erc unpack $TAR || fatal

mkdir -p opt
mv Loss* opt/$PRODUCT

VERSION=$(echo "$URL" | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+')
[ -n "$VERSION" ] || fatal "Can't get package version"

install_file https://raw.githubusercontent.com/mifi/lossless-cut/master/src/renderer/src/icon.svg /usr/share/icons/hicolor/scalable/apps/$PRODUCT.svg

# create desktop file
cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Type=Application
Name=LosslessCut
Comment=GUI tool for lossless trimming/cutting of media files
Exec=$PRODUCT
Categories=AudioVideo;
Icon=$PRODUCT
StartupWMClass=losslesscut
EOF

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
