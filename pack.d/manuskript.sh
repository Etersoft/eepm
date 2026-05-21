#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

PKGDIR="$PRODUCT"

dpkg-deb -R "$TAR" "$PKGDIR" || fatal

# Upstream deb still requires QtWebKit, but Debian 13 provides only QtWebEngine.
# Manuskript works with QtWebEngine, so patch the dependency instead of repacking files.
subst 's|python3-pyqt5.qtwebkit|python3-pyqt5.qtwebengine|' "$PKGDIR/DEBIAN/control"

dpkg-deb -b "$PKGDIR" "$PRODUCT.deb" || fatal
return_tar "$PRODUCT.deb"
