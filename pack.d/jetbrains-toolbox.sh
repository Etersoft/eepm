#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# use version from tarball
PKGNAME="$(basename $TAR .tar.gz)"
VERSION="$(echo $PKGNAME | sed -e 's/jetbrains-toolbox-//')"

erc $TAR || fatal
cd $PKGNAME* || fatal

# create svg icon
cat <<EOF > jetbrains-toolbox.svg
<svg data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" width="32" height="32"><defs><linearGradient id="a" x1="2.18" y1="23.255" x2="30.041" y2="8.782" gradientUnits="userSpaceOnUse"><stop offset=".043" stop-color="#ff8618"/><stop offset=".382" stop-color="#ff246e"/><stop offset=".989" stop-color="#af1df5"/></linearGradient></defs><title>ToolBox_trayIcon_colour_32-01</title><path d="M26,22.4713l-6.83,3.8311V23.2578L26,19.4268v3.0445Z" fill="#fff"/><path fill="#000001" d="M16 32.076L30 24.065 30 8.057 16 16.067 16 32.076"/><path fill="#fff" d="M18.925 24.641L18.925 27.041 25.026 23.55 25.026 21.15 18.925 24.641"/><path fill="url(#a)" d="M16 0.076L2 8.057 2 8.057 2 8.057 2 24.065 16 32.076 16 16.067 30 8.057 16 0.076"/></svg>
EOF

mkdir -p opt/jetbrains-toolbox usr/share/applications usr/share/icons/hicolor/scalable/apps
mv bin/* opt/jetbrains-toolbox/

install -Dm644 opt/jetbrains-toolbox/jetbrains-toolbox.desktop usr/share/applications/jetbrains-toolbox.desktop
install -Dm644 jetbrains-toolbox.svg usr/share/icons/hicolor/scalable/apps/jetbrains-toolbox.svg

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/C
license: Proprietary
url: https://www.jetbrains.com/ru-ru/toolbox-app/
summary: JetBrains Toolbox App
description: JetBrains Toolbox App.
EOF

erc pack $PKGNAME-$VERSION.tar opt usr || fatal 

return_tar $PKGNAME-$VERSION.tar
