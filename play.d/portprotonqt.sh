#!/bin/sh

PKGNAME=portprotonqt
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Modern GUI for managing and launching games from PortProton and Steam"
URL="https://git.linux-gaming.ru/Linux-Gaming/PortProtonQt"

. $(dirname $0)/common.sh

if [ "$PKGFORMAT" = "deb" ] ; then
    PKGURL="$(get_gitea_url "$URL" "${PKGNAME}_${VERSION}_amd64.deb")"
else
    [ -n "$RELEASE" ] || RELEASE="*"
    PKGURL="$(get_gitea_url "$URL" "${PKGNAME}-${VERSION}-${RELEASE}.fc43.x86_64.rpm")"
fi

install_pkgurl
