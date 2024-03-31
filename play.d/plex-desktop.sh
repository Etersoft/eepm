#!/bin/sh

PKGNAME=plex-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Plex Desktop from the official site"
URL="https://www.plex.tv/"

. $(dirname $0)/common.sh

# https://api.snapcraft.io/api/v1/snaps/download/qc6MFRM433ZhI1XjVzErdHivhSOhlpf0_37.snap
PKGURL="$(eget -O- -H Snap-Device-Series:16 https://api.snapcraft.io/v2/snaps/info/plex-desktop | epm --inscript tool json -b | grep '\["channel-map",0,"download","url"\]' | head -n1 | sed -e 's|.*"\(.*\)"$|\1|' )" || fatal "Can't get URL"

install_pkgurl
