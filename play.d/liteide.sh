#!/bin/sh

PKGNAME=liteide
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="LiteIDE is a simple, open source, cross-platform Go IDE. From the official site"
URL="https://github.com/visualfc/liteide"

. $(dirname $0)/common.sh

archbit="$(epm print info -b)"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/visualfc/liteide/" "liteidex.$VERSION.linux$archbit-qt5.*-system.tar.gz")
else
    PKGURL=$(get_github_version "https://github.com/visualfc/liteide/" "liteidex$VERSION.linux$archbit-qt5.*-system.tar.gz")
fi

install_pack_pkgurl
