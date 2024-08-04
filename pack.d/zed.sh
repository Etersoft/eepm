#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
URL="$4"

. $(dirname $0)/common.sh


VERSION=$(echo "$URL" | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+') 
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

mkdir -p opt/$PRODUCT
mkdir -p usr/

erc unpack $TAR || fatal
mv zed.app/* opt/$PRODUCT/

chmod 755 opt/$PRODUCT/libexec/zed-editor

mv opt/$PRODUCT/share usr/

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Editors
license: GPL-3.0 and AGPL-3.0 and Apache-2.0
url: https://zed.dev/
summary: High-performance, multiplayer code editor
description: High-performance, multiplayer code editor
EOF

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
