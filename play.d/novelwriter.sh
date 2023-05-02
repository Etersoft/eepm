#!/bin/sh

PKGNAME=novelwriter
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="novelWriter - a markdown-like editor for novels"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

# https://github.com/vkbo/novelWriter/releases/download/v2.0.7/novelwriter_2.0.7_all.deb
PKGURL=$(epm tool eget --list --latest https://github.com/vkbo/novelWriter/releases "novelwriter_${VERSION}_all.$pkgtype") || fatal "Can't get package URL"

epm install "$PKGURL"
