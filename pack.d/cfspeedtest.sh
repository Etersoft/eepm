#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

erc unpack "$TAR" || fatal

install -D -m755 $PRODUCT usr/bin/$PRODUCT || fatal

erc pack $PKGNAME.tar usr/bin || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Other
license: MIT
url: https://github.com/code-inflation/cfspeedtest
summary: Unofficial CLI for speed.cloudflare.com
description: CLI tool to test internet speed against Cloudflare's edge network.
EOF

return_tar $PKGNAME.tar
