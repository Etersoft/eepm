#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

# The upstream DwarFS AppImage has a built-in extractor.
chmod a+x "$TAR" || fatal
"$TAR" --appimage-extract || fatal

[ -n "$VERSION" ] || VERSION=$(basename "$TAR" | cut -d_ -f2)
PKGNAME="$PRODUCT-$VERSION.tar"

mkdir -p opt
if [ -d AppDir ] ; then
    mv AppDir "opt/$PRODUCT" || fatal
else
    mv squashfs-root "opt/$PRODUCT" || fatal
fi

install_file "opt/$PRODUCT/$PRODUCT.desktop" "/usr/share/applications/$PRODUCT.desktop"
install_file "opt/$PRODUCT/$PRODUCT.png" "/usr/share/pixmaps/$PRODUCT.png"

cat <<EOF >"$PKGNAME.eepm.yaml"
name: $PRODUCT
version: $VERSION
upstream_file: $(basename "$TAR")
EOF

erc pack "$PKGNAME" opt usr || fatal
return_tar "$PKGNAME"
