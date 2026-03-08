#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(basename "$TAR" | sed -E 's/^[^.]+\.[^.]+\.(.+)\.linux.*/\1/')"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

mkdir -p opt
erc unpack "$TAR" || fatal
mv Radarr opt/$PRODUCT

erc pack $PKGNAME.tar opt || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Other
license: GPLv3
url: https://radarr.video/
summary: Movie library manager
description: Radarr is a movie collection manager for Usenet and BitTorrent users.
EOF

return_tar $PKGNAME.tar
