#!/bin/sh

PKGNAME=viber
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Viber for Linux from the official site"
URL="https://viber.com"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://download.cdn.viber.com/desktop/Linux/viber.AppImage"

epm install "$PKGURL"
