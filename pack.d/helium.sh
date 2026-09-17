#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

VERSION="$(basename "$TAR" | sed -e "s|.*${PRODUCT}[-_]||" -e 's|^\([0-9.]*\).*|\1|')"
PKGNAME="$PRODUCT-$VERSION"

erc -C opt/$PRODUCT $TAR || fatal

erc a $PKGNAME.tar opt

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/WWW
license: GPL-3.0-only AND BSD-3-Clause
url: https://github.com/imputnet/helium-linux
summary: Private, fast, and honest web browser based on Chromium
description: Private, fast, and honest web browser based on Chromium
EOF

return_tar $PKGNAME.tar
