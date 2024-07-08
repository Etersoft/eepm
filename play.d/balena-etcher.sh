#!/bin/sh

PKGNAME=balena-etcher
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Flash OS images to SD cards & USB drives, safely and easily"
URL="https://etcher.io/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/balena-io/etcher/" "balena-etcher_.${VERSION}_amd64.deb")
else
    PKGURL="https://github.com/balena-io/etcher/releases/download/v$VERSION/${PKGNAME}_${VERSION}_amd64.deb"
fi

install_pkgurl
