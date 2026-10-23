#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE 'lemonade-embeddable-[0-9.]+-' | sed -e 's|lemonade-embeddable-||' -e 's|-$||')"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION
PRODUCTDIR=opt/lemonade

erc --here unpack "$TAR" || fatal

SRCDIR="$(find . -maxdepth 1 -type d -name 'lemonade-embeddable-*' | head -n1)"
[ -n "$SRCDIR" ] || fatal "Can't find extracted Lemonade directory"

mkdir -p "$PRODUCTDIR" || fatal
cp -a "$SRCDIR/." "$PRODUCTDIR/" || fatal

erc pack "$PKGNAME.tar" opt || fatal

cat <<EOF >"$PKGNAME.tar.eepm.yaml"
name: $PRODUCT
group: Development/Other
license: Apache-2.0
url: https://github.com/lemonade-sdk/lemonade
summary: Local LLM server with GPU and NPU acceleration
description: Lemonade is a local LLM server with GPU and NPU acceleration.
EOF

return_tar "$PKGNAME.tar"
