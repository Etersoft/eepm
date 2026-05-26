#!/bin/sh

PKGNAME=portprotonqt
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Modern GUI for managing and launching games from PortProton and Steam"
URL="https://git.linux-gaming.ru/Linux-Gaming/PortProtonQt"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
   VERSION=$(curl -Ls https://git.linux-gaming.ru/Linux-Gaming/PortProtonQt/raw/branch/main/CHANGELOG.md | awk '/^## \[[0-9]/{sub(/^## \[/,"");sub(/\].*/,"");print;exit}')
fi

PKGURL="$(eget --list --latest "https://git.linux-gaming.ru/Linux-Gaming/PortProtonQt/releases/tag/v${VERSION}" "${PKGNAME}-${VERSION}-*.x86_64.rpm")"

install_pkgurl
