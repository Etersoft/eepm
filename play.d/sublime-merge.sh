#!/bin/sh

PKGNAME=sublime-merge
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Sublime Merge - Git client from the makers of Sublime Text"
URL="https://www.sublimemerge.com/"
TIPS="Run epm play sublime-merge=BUILD to install specific build (e.g. 2121)."

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -q -O- https://www.sublimemerge.com/download | grep -oP 'sublime-merge-\K[0-9]+' | head -1)
    [ -n "$VERSION" ] || fatal "Can't get version"
    RELEASE="1"
fi

PKGURL="https://download.sublimetext.com/sublime-merge-${VERSION}-${RELEASE}.x86_64.rpm"

install_pkgurl
