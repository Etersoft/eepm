#!/bin/sh

PKGNAME=Heroic
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Is an Open Source Game Launcher for Linux. It supports launching games from the Epic Games Store, GOG Games and Amazon Games'
URL="https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

case $pkgtype in
    rpm)
        pkgformat="rpm"
        arch=$(epm print info -a)
        ;;
    *)
        pkgformat="deb"
        arch=$(epm print info --debian-arch)
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/" "${PKGNAME}-${VERSION}-linux-$arch.$pkgformat")
else
    PKGURL="https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/v$VERSION/${PKGNAME}-${VERSION}-linux-$arch.$pkgformat"
fi

install_pkgurl
