#!/bin/sh

PKGNAME=rocketchat
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Rocket.Chat Linux Desktop Client from the official site'
URL="https://github.com/RocketChat/Rocket.Chat.Electron"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

PKGURL=$(get_github_version "https://github.com/RocketChat/Rocket.Chat.Electron/" "$PKGNAME.*.$VERSION.*$arch.$pkgtype")

install_pkgurl
