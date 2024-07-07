#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

mkdir -p opt/
erc unpack $TAR || fatal
mv $PRODUCT* opt/$PRODUCT
chmod 0755 opt/$PRODUCT/glxtest

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/WWW
license: MPL-2.0
url: https://www.waterfox.net/
summary: Fast and Private Web Browser
description: Fast and Private Web Browser
EOF

erc pack $PKGNAME.tar opt || fatal

return_tar $PKGNAME.tar
