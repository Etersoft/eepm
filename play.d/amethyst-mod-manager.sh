#!/bin/sh

PKGNAME=amethyst-mod-manager
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Amethyst Mod Manager - a Linux native mod manager for a variety of games"
URL="https://github.com/ChrisDKN/Amethyst-Mod-Manager"

. $(dirname $0)/common.sh

epm assure dwarfsextract dwarfs-tools || fatal

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "AmethystModManager-$VERSION-x86_64.AppImage")
else
    PKGURL="$URL/releases/download/v$VERSION/AmethystModManager-$VERSION-x86_64.AppImage"
fi

install_pkgurl
