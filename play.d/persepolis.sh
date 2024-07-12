#!/bin/sh

PKGNAME=persepolis
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='is a download manager & a GUI for Aria2'
URL="https://persepolisdm.github.io/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/persepolisdm/persepolis/" "${PKGNAME}_.${VERSION}_all.deb")
else
    PKGURL="https://github.com/persepolisdm/persepolis/releases/download/$VERSION/${PKGNAME}_${VERSION}_all.deb"
fi

install_pkgurl
