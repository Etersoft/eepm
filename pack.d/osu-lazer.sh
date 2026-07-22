#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

# Upstream publishes the AppImage as osu.AppImage, but the package is osu-lazer.
VERSION=$(echo "$URL" | sed -n 's|.*/download/\([^/][^/]*\)/.*|\1|p')
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME="$PRODUCT-$VERSION.AppImage"

mv "$TAR" "$PKGNAME" || fatal

cat <<EOF >"$PKGNAME.eepm.yaml"
name: $PRODUCT
version: $VERSION
upstream_file: $(basename "$TAR")
generic_repack: appimage
EOF

return_tar "$PKGNAME"
