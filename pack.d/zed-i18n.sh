#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh


[ -n "$VERSION" ] || VERSION=$(printf '%s\n' "$URL" | sed -nE 's|.*/v([0-9]+\.[0-9]+\.[0-9]+)-i18n\.([0-9]+)/.*|\1.i18n.\2|p')
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

mkdir -p usr/

erc -C opt/$PRODUCT unpack $TAR || fatal

chmod 755 opt/$PRODUCT/libexec/zed-editor

mv opt/$PRODUCT/share usr/

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Editors
license: GPL-3.0 and AGPL-3.0 and Apache-2.0
url: https://github.com/LI-NA/zed-i18n
summary: Zed editor with multilingual interface
description: Zed editor with multilingual interface
EOF

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
