#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# the tar contains the only ELF binary trustviewer
erc -C opt/$PRODUCT unpack "$TAR" || fatal
[ -s opt/$PRODUCT/trustviewer ] || fatal "Can't find trustviewer binary in $TAR"
chmod 0755 opt/$PRODUCT/trustviewer

mkdir -p usr/share/applications
cat <<EOF2 >usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Type=Application
Name=TrustViewer
Comment=Remote access and support
Exec=$PRODUCT
Icon=preferences-desktop-remote-desktop
Terminal=false
Categories=Network;RemoteAccess;
EOF2

# no version in the archive name and in the binary, use the file date
VERSION="$(date -r "$TAR" "+%Y.%m.%d")"
PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

cat <<EOF2 >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Remote access
license: Proprietary
url: https://trustservice.tech/
summary: TrustViewer - free remote access
description: TrustViewer - free remote access and support tool.
EOF2

return_tar $PKGNAME.tar
