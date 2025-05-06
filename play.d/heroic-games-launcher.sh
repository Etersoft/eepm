#!/bin/sh

PKGNAME=Heroic
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Is an Open Source Game Launcher for Linux. It supports launching games from the Epic Games Store, GOG Games and Amazon Games'
URL="https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher"

. $(dirname $0)/common.sh

arch=x86_64
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/" "${PKGNAME}-${VERSION}-linux-$arch.AppImage")
else
    PKGURL="https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/v$VERSION/${PKGNAME}-${VERSION}-linux-$arch.AppImage"
fi

install_pkgurl
