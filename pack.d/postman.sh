#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh


# postman-linux-x64.tar.gz
BASENAME=$(basename $TAR .tar.gz)

ln -s $TAR $BASENAME.tar.gz
erc unpack $BASENAME.tar.gz || fatal

mkdir -p opt
mv Postman/app opt/postman

VERSION=$(cat "opt/postman/resources/app/package.json" | epm --inscript tool json -b | grep version | awk 'gsub(/"/, "", $2) {print $2}') #'
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
