#!/bin/sh

PKGNAME=portprotonqt
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Modern GUI for managing and launching games from PortProton and Steam"
URL="https://git.linux-gaming.ru/Linux-Gaming/PortProtonQt"

. $(dirname $0)/common.sh

PKGURL="$(get_gitea_url "$URL" "${PKGNAME}-${VERSION}-*.x86_64.rpm")"

install_pkgurl
