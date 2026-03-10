#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc --here unpack $TAR || fatal

mkdir -p opt
mv Postman/app opt/postman

VERSION="$(get_json_value opt/postman/resources/app/package.json version)"
[ -n "$VERSION" ] || fatal "Can't get package version"

install_file opt/postman/resources/app/assets/icon.png /usr/share/pixmaps/postman.png

# create desktop file
cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Postman
Comment=Postman API platform 
Exec=$PRODUCT %U
Icon=$PRODUCT
Terminal=false
StartupNotify=true
Categories=Development;IDE;
StartupWMClass=postman
MimeType=x-scheme-handler/postman
EOF

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
