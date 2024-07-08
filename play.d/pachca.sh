#!/bin/sh

PKGNAME=pachca
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Корпоративный мессенджер Пачка с официального сайта"
URL="https://github.com/pachca/pachca-desktop"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/pachca/pachca-desktop" "${PKGNAME}_.${VERSION}_$arch.deb")
else
    PKGURL="https://github.com/pachca/pachca-desktop/releases/download/v$VERSION/${PKGNAME}_${VERSION}_$arch.deb"
fi

install_pkgurl
