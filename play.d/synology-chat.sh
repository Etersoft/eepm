#!/bin/sh

PKGNAME=chat
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Synology Chat Client from the official site'
URL="https://synology.com"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION="[0-9]*"

urldir="$(eget --list https://archive.synology.com/download/Utility/ChatClient "/$VERSION-*" | head -n1)"
[ -n "$urldir" ] || fatal "Can't get dir for $VERSION version on https://archive.synology.com/download/Utility/ChatClient"

# use temp dir
PKGDIR="$(mktemp -d)"
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

PKGURL="$PKGNAME.deb"
# fix spaces in the package name
eget -O $PKGURL "$urldir/Synology*.deb"

install_pkgurl
