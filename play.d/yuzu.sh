#!/bin/sh

PKGNAME=yuzu-mainline
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="yuzu is the world's most popular, open-source, Nintendo Switch emulator"
URL="https://github.com/yuzu-emu/yuzu-mainline/releases"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] || VERSION="$VERSION-*"

PKGURL=$(epm tool eget --list --latest https://github.com/yuzu-emu/yuzu-mainline/releases "$PKGNAME-$VERSION.AppImage")

epm install $PKGURL
