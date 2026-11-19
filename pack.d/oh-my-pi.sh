#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

install -D -m755 "$TAR" usr/bin/omp || fatal

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Development/Tools
license: MIT
url: https://github.com/can1357/oh-my-pi
summary: Oh My Pi coding agent
description: Terminal AI coding agent with multi-model support and built-in development tools.
EOF

return_tar $PKGNAME.tar
