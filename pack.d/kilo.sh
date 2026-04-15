#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

mkdir -p usr/bin
erc --here unpack "$TAR" || fatal

mv kilo usr/bin/kilo || fatal
chmod 755 usr/bin/kilo

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr/bin || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: MIT
url: https://github.com/Kilo-Org/kilocode
summary: Killo Code
description: Kilo is the all-in-one agentic engineering platform.
EOF

return_tar $PKGNAME.tar
