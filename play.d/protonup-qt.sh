#!/bin/sh

PKGNAME=ProtonUp-Qt
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Install and manage GE-Proton and Luxtorpeda for Steam and Wine-GE for Lutris with this graphical user interface'
URL="https://github.com/DavidoTek/ProtonUp-Qt"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/DavidoTek/ProtonUp-Qt/" "$PKGNAME-.$VERSION-x86_64.AppImage")
else
    PKGURL="https://github.com/DavidoTek/ProtonUp-Qt/releases/download/v$VERSION/$PKGNAME-$VERSION-x86_64.AppImage"
fi

install_pkgurl
