#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

mkdir -p usr/bin

erc --here unpack $TAR || fatal
mv kimi usr/bin/kimi || fatal
chmod 755 usr/bin/kimi

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: MIT
url: https://github.com/MoonshotAI/kimi-code
summary: The Starting Point for Next-Gen Agents
description: The Starting Point for Next-Gen Agents
EOF

return_tar $PKGNAME.tar
