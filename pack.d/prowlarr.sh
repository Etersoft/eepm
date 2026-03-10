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
url: https://prowlarr.com/
summary: Indexer manager for Sonarr, Radarr and Lidarr
description: Prowlarr is an indexer manager/proxy for PVR apps like Sonarr, Radarr and Lidarr.
EOF

return_tar $PKGNAME.tar
