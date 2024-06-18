#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
. $(dirname $0)/common.sh

# xeoma_linux64.tgz
erc unpack $TAR || fatal

mkdir -p opt/xeoma
mv xeoma.app* opt/xeoma/xeoma

install_file ipfs://QmaVnzNmFjR3BmA5b4jzjwo4MNBRkN7UoewiKotDULbCH5 usr/share/icons/hicolor/512x512/apps/$PRODUCT.png

# create desktop file
cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Xeoma
Comment=Video surveillance with AI video analytics
Exec=$PRODUCT %U
Icon=$PRODUCT
Terminal=false
StartupNotify=true
Categories=Video;
StartupWMClass=xeoma
MimeType=x-scheme-handler/xeoma
EOF

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
