#!/bin/sh

PKGNAME=EpicGamesLauncher
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Epic Games Launcher from the official site"
URL="https://launcher.epicgames.com/"

. $(dirname $0)/common.sh

# version is like 0.97.0+g4f63cc1 (build hash is a part of the download path)
if [ "$VERSION" = "*" ] ; then
    # eget --get-real-url keeps the original URL since the redirect target has a query string
    VERSION="$(eget --get-response "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncher-x86_64.AppImage" | grep -i '^location:' | sed -e 's|.*/Builds/EGLv2/||' -e 's|/Linux/.*||' -e 's|%2B|+|g')"
    [ -n "$VERSION" ] || fatal "Can't get version for $PKGNAME"
fi

export EPM_REPACK_VERSION="$VERSION"

PKGURL="https://content-download-egs.distro.on.epicgames.com/Builds/EGLv2/$(echo "$VERSION" | sed -e 's|+|%2B|g')/Linux/EpicGamesLauncher-x86_64.AppImage"

install_pkgurl
