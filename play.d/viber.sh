#!/bin/sh

PKGNAME=viber
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Viber for Linux from the official site"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] || fatal "Only latest Viber version is allowed"

PKGURL="https://download.cdn.viber.com/desktop/Linux/viber.AppImage"

epm install "$PKGURL"
