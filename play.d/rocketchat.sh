#!/bin/sh

PKGNAME=rocketchat
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Rocket.Chat Linux Desktop Client from the official site'
URL="https://github.com/RocketChat/Rocket.Chat.Electron"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

# VERSION from app-versions may contain ~ instead of - (rpm convention)
URLVERSION="$(echo "$VERSION" | tr '~' '-')"
PKGURL=$(eget --list --latest https://github.com/RocketChat/Rocket.Chat.Electron/releases/ "$PKGNAME*$URLVERSION*$arch.$pkgtype")

install_pkgurl
