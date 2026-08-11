#!/bin/sh

PKGNAME=git-butler
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="GitButler - Git client for modern workflows (branches, undo, AI)"
URL="https://gitbutler.com/"

. $(dirname $0)/common.sh

if [ "$VERSION" != "*" ] && echo "$VERSION" | grep -q '~' ; then
    ver="${VERSION%~*}"
    build="${VERSION#*~}"
    build_version="$ver-$build"

    PKGURL="https://releases.gitbutler.com/releases/release/$build_version/linux/x86_64/GitButler_${ver}_amd64.deb"

    export EPM_REPACK_VERSION="$VERSION"
    install_pkgurl
    exit
fi

# Upstream rpm has an empty License tag and fails rpmbuild during repack.
PKGURL="https://app.gitbutler.com/downloads/release/linux/x86_64/deb"

install_pkgurl
