#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

# https://github.com/zen-browser/desktop/releases/download/1.10b/zen-x86_64.AppImage
VERSION=$(echo "$URL" | grep -oP 'download/\K[0-9]+\.[0-9a-e]+')
[ -n "$VERSION" ] || fatal "Can't get package version"

# rename package
PKGNAME="$PRODUCT-$VERSION.AppImage"

mv $TAR $PKGNAME || fatal

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
upstream_file: $(basename $TAR)
generic_repack: appimage
EOF

return_tar $PKGNAME
