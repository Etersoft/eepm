#!/bin/sh

PKGNAME=Everdo
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A productivity app for GTD (Getting Things Done) from the official site"
URL="https://everdo.net/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# https://release.everdo.net/1.9.0/everdo_1.9.0_amd64.deb
# https://release.everdo.net/1.9.0/Everdo-1.9.0.AppImage

# no more .deb
#PKGURL=$(eget --list --latest "https://everdo.net/getting-started/?d=deb" "$PKGNAME*.deb")

PKGURL=$(eget --list --latest "https://everdo.net/getting-started/?d=appimage" "$PKGNAME*.AppImage")

install_pkgurl

