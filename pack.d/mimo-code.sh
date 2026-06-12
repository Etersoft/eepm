#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

erc -C usr/bin unpack "$TAR" || fatal

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr/bin || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: MIT
url: https://github.com/XiaomiMiMo/MiMo-Code
summary: MiMo Code, the AI coding agent by Xiaomi
description: MiMo Code is an AI coding agent for the terminal by Xiaomi, powered by MiMo models.
EOF

return_tar $PKGNAME.tar
