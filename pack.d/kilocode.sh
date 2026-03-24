#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
[ -n "$VERSION" ] || fatal "Can't get package version"

erc --here unpack "$TAR" || fatal
mkdir -p usr/bin
mv kilo usr/bin/kilo || fatal
chmod 755 usr/bin/kilo

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr/bin || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: Apache-2.0
url: https://github.com/Kilo-Org/kilocode
summary: Kilo Code CLI tool
description: Kilo Code is an open-source agentic coding platform and CLI tool for AI-assisted development.
EOF

return_tar $PKGNAME.tar
