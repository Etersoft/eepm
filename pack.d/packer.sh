#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

erc --flat -C usr/bin unpack "$TAR" || fatal
chmod 755 usr/bin/$PRODUCT || fatal

erc pack $PKGNAME.tar usr/bin || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: BUSL-1.1
url: https://developer.hashicorp.com/packer
summary: Machine image creation tool
description: A tool for creating identical machine images for multiple platforms from a single source configuration.
EOF

return_tar $PKGNAME.tar
