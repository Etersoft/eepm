#!/bin/sh

PKGNAME=rpcs3
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="RPCS3 - free and open-source PlayStation 3 emulator from the official site"
URL="https://rpcs3.net/download"

. $(dirname $0)/common.sh

file="rpcs3-v${VERSION}-*-*_linux64.AppImage"

PKGURL=$(eget --list --latest https://github.com/RPCS3/rpcs3-binaries-linux/releases "$file") || fatal "Can't get package URL"

epm pack --install "$PKGNAME" "$PKGURL"
