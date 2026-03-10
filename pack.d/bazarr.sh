#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

erc -C opt/$PRODUCT unpack "$TAR" || fatal

erc pack $PKGNAME.tar opt || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Other
license: GPLv3
url: https://www.bazarr.media/
summary: Subtitle manager for Sonarr and Radarr
description: Bazarr is a companion application to Sonarr and Radarr that manages and downloads subtitles.
EOF

return_tar $PKGNAME.tar
