#!/bin/sh

PKGNAME=novelwriter
SUPPORTEDARCHES=""
VERSION="$2"
DESCRIPTION="novelWriter - a markdown-like editor for novels"
URL="https://github.com/vkbo/novelWriter"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

# 2.4.b1 support
[ "$VERSION" = "*" ] || VERSION="$VERSION.*"

# https://github.com/vkbo/novelWriter/releases/download/v2.0.7/novelwriter_2.0.7_all.deb
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/vkbo/novelWriter/" "novelwriter_.${VERSION}_all.$pkgtype")
else
    PKGURL=$(get_github_version "https://github.com/vkbo/novelWriter/" "novelwriter_${VERSION}_all.$pkgtype")
fi

install_pkgurl
