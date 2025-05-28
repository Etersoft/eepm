#!/bin/sh

PKGNAME=muffon
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='muffon is a cross-platform music streaming client for desktop, which helps you listen to, discover and organize music in an advanced way.'
URL="https://github.com/staniel359/muffon"

. $(dirname $0)/common.sh

arch="$(epm print info --distro-arch)"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/staniel359/muffon" "${PKGNAME}-${VERSION}-linux-$arch.AppImage")
else
    PKGURL="https://github.com/staniel359/muffon/releases/download/v$VERSION/${PKGNAME}-${VERSION}-linux-$arch.AppImage"
fi

install_pkgurl
