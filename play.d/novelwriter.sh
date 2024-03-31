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
[ "$VERSION" = "*" ] || VERSION="$VERSION*"

# https://github.com/vkbo/novelWriter/releases/download/v2.0.7/novelwriter_2.0.7_all.deb
PKGURL=$(eget --list --latest https://github.com/vkbo/novelWriter/releases "novelwriter_${VERSION}_all.$pkgtype") || fatal "Can't get package URL"

install_pkgurl
