#!/bin/sh

PKGNAME=ahk_x11
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='AutoHotkey for Linux (X11-based systems)'
URL="https://github.com/phil294/AHK_X11"

. $(dirname $0)/common.sh

arch=x86_64
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/phil294/AHK_X11" "${PKGNAME}.AppImage")
else
    PKGURL="https://github.com/phil294/AHK_X11/releases/download/$VERSION/${PKGNAME}.AppImage"
fi

install_pkgurl
