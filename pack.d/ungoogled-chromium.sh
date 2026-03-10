#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

# ungoogled-chromium-145.0.7632.75-1-x86_64_linux.tar.xz
VERSION="$(basename "$TAR" | sed -e "s|.*${PRODUCT}[-_]||" -e 's|^\([0-9.]*\).*|\1|')"
PKGNAME="$PRODUCT-$VERSION"

erc -C opt/$PRODUCT $TAR || fatal

erc a $PKGNAME.tar opt

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/WWW
license: BSD-3-Clause license
url: https://github.com/ungoogled-software/ungoogled-chromium-portablelinux
summary: Google Chromium, sans integration with Google
description: Google Chromium, sans integration with Google.
EOF

return_tar $PKGNAME.tar
