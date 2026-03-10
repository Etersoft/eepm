#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(basename "$TAR" | sed -E 's/^[^.]+\.[^.]+\.(.+)\.linux.*/\1/')"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

erc -C opt/$PRODUCT unpack "$TAR" || fatal

erc pack $PKGNAME.tar opt || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Other
license: GPLv3
url: https://lidarr.audio/
summary: Music library manager
description: Lidarr is a music collection manager for Usenet and BitTorrent users.
EOF

return_tar $PKGNAME.tar
