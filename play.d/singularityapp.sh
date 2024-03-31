#!/bin/sh

PKGNAME=singularityapp
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="SingularityApp from the official site"
URL="https://snapcraft.io/singularityapp"

. $(dirname $0)/common.sh

SNAPNAME="singularityapp"
# https://api.snapcraft.io/api/v1/snaps/download/qc6MFRM433ZhI1XjVzErdHivhSOhlpf0_37.snap
PKGURL="$(eget -O- -H Snap-Device-Series:16 https://api.snapcraft.io/v2/snaps/info/$SNAPNAME | epm --inscript tool json -b | grep '\["channel-map",0,"download","url"\]' | head -n1 | sed -e 's|.*"\(.*\)"$|\1|' )"

install_pkgurl
