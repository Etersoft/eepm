#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | sed -n -e 's#.*/releases/download/launcher\(@\|%40\)\([^/]*\)/.*#\2#p')"
[ -n "$VERSION" ] || fatal "Can't get package version"
PKGNAME="$PRODUCT-$VERSION"

erc -C opt/$PRODUCT "$TAR" || fatal

mkdir -p usr/share/applications usr/share/icons/hicolor/scalable/apps
eget -O usr/share/icons/hicolor/scalable/apps/horizon.svg "https://raw.githubusercontent.com/horizon-rust/horizon/launcher@$VERSION/packaging/icons/hicolor/scalable/apps/horizon.svg" || fatal "Can't download Horizon icon"
cat >usr/share/applications/horizon-launcher.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Horizon Launcher
Comment=Launcher for Horizon
Exec=horizon-launcher
TryExec=horizon-launcher
Icon=horizon
Terminal=false
Categories=Game;
EOF

erc a "$PKGNAME.tar" opt usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Games/Other
license: MIT AND OFL-1.1
url: https://github.com/horizon-rust/horizon
summary: Horizon launcher for Minecraft Java Edition rewritten in Rust
EOF

return_tar "$PKGNAME.tar"
