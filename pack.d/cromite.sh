#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc -C opt/$PRODUCT unpack "$TAR" || fatal

VERSION="$(LC_ALL=C grep -aoE 'Chrome/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "opt/$PRODUCT/chrome" | head -n1 | cut -d/ -f2)"
[ -n "$VERSION" ] || fatal "Can't get Cromite version"
PKGNAME="$PRODUCT-$VERSION"

erc pack "$PKGNAME.tar" opt || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/WWW
license: GPL-3.0
url: https://github.com/uazo/cromite
summary: Chromium fork with ad blocking and privacy enhancements
description: Chromium fork with ad blocking and privacy enhancements.
EOF

return_tar "$PKGNAME.tar"
