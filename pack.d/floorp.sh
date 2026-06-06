#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"

PKGNAME=$PRODUCT-$VERSION

erc -C opt/$PRODUCT unpack $TAR || fatal
chmod 0755 opt/$PRODUCT/glxtest

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/WWW
license: MPL-2.0
url: https://github.com/Floorp-Projects/Floorp
summary: Firefox-based web browser focused on performance and customizability
description: Firefox-based web browser focused on performance and customizability
EOF

erc pack $PKGNAME.tar opt || fatal

return_tar $PKGNAME.tar
