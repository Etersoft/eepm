#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

# ungoogled-chromium_113.0.5672.127-1.1_linux.tar.xz
PKGNAME="$(basename "$TAR" | sed -e 's|-[0-9].*||' -e 's|_|-|' )"

mkdir opt/
erc $TAR
mv -v $PRODUCT* opt/$PRODUCT

erc a $PKGNAME.tar opt

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/WWW
license: BSD-3-Clause license
url: https://www.sublimetext.com
summary: Google Chromium, sans integration with Google
description: Google Chromium, sans integration with Google.
EOF

return_tar $PKGNAME.tar
