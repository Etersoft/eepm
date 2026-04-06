#!/bin/sh

PKGNAME=rocketchat
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Rocket.Chat Linux Desktop Client from the official site'
URL="https://github.com/RocketChat/Rocket.Chat.Electron"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(eget --list --latest https://github.com/RocketChat/Rocket.Chat.Electron/releases/ "$PKGNAME*$arch.$pkgtype")
else
    PKGURL="https://github.com/RocketChat/Rocket.Chat.Electron/releases/download/$VERSION/${PKGNAME}_${VERSION}_${arch}.${pkgtype}"
fi

install_pkgurl
