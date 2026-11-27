#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PRODUCT=ProtonUp-Qt
BASEDIR="$(basename "$TAR" .AppImage)"
[ -n "$VERSION" ] || VERSION="$(echo "$BASEDIR" | sed -e 's|^ProtonUp-Qt-||' -e 's|-x86_64$||')"

epm assure unsquashfs squashfs-tools || fatal
erc --here -C "$BASEDIR" unpack "$TAR" || fatal

# Upstream ships read-only files and directories; repack needs owner write access.
chmod -R u+rwX,go+rX,go-w "$BASEDIR" || fatal

PKGNAME="$PRODUCT-$VERSION.tar"
erc pack "$PKGNAME" "$BASEDIR" || fatal

cat <<EOF >"$PKGNAME.eepm.yaml"
name: $PRODUCT
version: $VERSION
summary: Install and manage Proton and Wine compatibility tools
url: https://github.com/DavidoTek/ProtonUp-Qt
license: GPL-3.0
upstream_file: $(basename "$TAR")
EOF

return_tar "$PKGNAME"
