#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || fatal "Can't get package version"

erc --here unpack "$TAR" || fatal
[ -d usr/lib/millennium ] || fatal "Can't find usr/lib/millennium in archive"

PKGNAME=$PRODUCT-$VERSION

erc pack "$PKGNAME.tar" usr || fatal

cat <<EOF >"$PKGNAME.tar.eepm.yaml"
name: $PRODUCT
version: $VERSION
group: Games
license: MIT
url: https://github.com/SteamClientHomebrew/Millennium
summary: Modding framework for Steam Client themes and plugins
description: Open-source modding framework for creating and managing Steam Client themes and plugins.
EOF

return_tar "$PKGNAME.tar"
