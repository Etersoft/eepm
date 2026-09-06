#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || fatal "Can't get package version"

# Upstream's Ubuntu-specific filename must not become part of the package name.
PKGNAME="$PRODUCT-$VERSION.AppImage"
mv "$TAR" "$PKGNAME" || fatal

cat <<EOF >"$PKGNAME.eepm.yaml"
name: $PRODUCT
version: $VERSION
group: Networking/Remote access
summary: Display and control Android devices via USB or network
description: QtScrcpy displays and controls Android devices via USB or network without root access.
license: Apache-2.0
url: $URL
upstream_file: $(basename "$TAR")
generic_repack: appimage
EOF

return_tar "$PKGNAME"
