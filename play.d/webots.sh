#!/bin/sh

PKGNAME=webots
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Webots: open-source robot simulator"
URL="https://cyberbotics.com/"

. $(dirname $0)/common.sh


if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/cyberbotics/webots" "webots_${VERSION}_amd64.deb")
else
    PKGURL="https://github.com/cyberbotics/webots/releases/download/R$VERSION/webots_${VERSION}_amd64.deb"
fi

install_pkgurl
