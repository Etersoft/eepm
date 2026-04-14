#!/bin/sh

PKGNAME=synology-chat
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Synology Chat Client from the official site'
URL="https://synology.com"

. $(dirname $0)/common.sh

if [ "$VERSION" != "*" ] ; then
    # VERSION from app-versions: 1.2.3~232 -> use only major version for directory search
    VERSION="$(echo "$VERSION" | sed 's|[~-].*||')"
fi
[ "$VERSION" = "*" ] && VERSION="[0-9]*"

urldir="$(eget --list https://archive.synology.com/download/Utility/ChatClient "/$VERSION-*" | head -n1)"
[ -n "$urldir" ] || fatal "Can't get dir for $VERSION version on https://archive.synology.com/download/Utility/ChatClient"

cd_to_temp_dir

PKGURL="$PKGNAME.deb"
# fix spaces in the package name
eget -O $PKGURL "$urldir/Synology*.deb"

install_pkgurl
