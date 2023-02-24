#!/bin/sh

PKGNAME=rocketchat
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Rocket.Chat Linux Desktop Client from the official site'

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

PKG=$(epm tool eget --list --latest https://github.com/RocketChat/Rocket.Chat.Electron/releases/ "$PKGNAME*$arch.$pkgtype") || fatal "Can't get package URL"
[ -n "$PKG" ] || fatal "Can't get package URL"

epm install "$PKG"
