#!/bin/sh

PKGNAME=yuzu-mainline
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="yuzu is the world's most popular, open-source, Nintendo Switch emulator"
URL="https://github.com/yuzu-emu/yuzu-mainline/releases"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] || VERSION="$VERSION-*"

# Closed by Nintendo
#PKGURL=$(eget --list --latest https://github.com/yuzu-emu/yuzu-mainline/releases "$PKGNAME-$VERSION.AppImage")
# https://github.com/yuzu-emu/yuzu-mainline/releases/download/mainline-0-1733/yuzu-mainline-20240303-7ffac53c9.AppImage
PKGURL="ipfs://QmVQ9La5aqL89mm6PkiYfBn5nF9NyhFsuWyaesY3k9JsUN?filename=yuzu-mainline-20240303-7ffac53c9.AppImage"

epm install "$PKGURL"
