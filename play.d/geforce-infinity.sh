#!/bin/sh

PKGNAME=GeForceInfinity-linux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Is a next-gen application designed to enhance the GeForce NOW experience'
URL="https://github.com/AstralVixen/GeForce-Infinity"

. $(dirname $0)/common.sh

arch=x86_64
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/AstralVixen/GeForce-Infinity" "${PKGNAME}-${VERSION}-$arch.AppImage")
else
    PKGURL="https://github.com/AstralVixen/GeForce-Infinity/releases/download/$VERSION/${PKGNAME}-${VERSION}-$arch.AppImage"
fi

install_pkgurl
