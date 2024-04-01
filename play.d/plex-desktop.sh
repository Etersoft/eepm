#!/bin/sh

PKGNAME=plex-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Plex Desktop from the official site"
URL="https://www.plex.tv/"

. $(dirname $0)/common.sh

PKGURL="$(snap_get_pkgurl $PKGNAME)"

install_pkgurl
