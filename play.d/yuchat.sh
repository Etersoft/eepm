#!/bin/sh

PKGNAME=YuChat
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='YuChat - corporate messenger from the official site'
URL="https://yuchat.ai/"

. $(dirname $0)/common.sh

BASEURL="https://downloads.yuchat.ai/linux"

if [ "$VERSION" = "*" ] ; then
    VERSION="$(fetch_url "$BASEURL/latest-linux.yml" | awk '/^version:/{print $2; exit}' | tr -d '\r')"
    [ -n "$VERSION" ] || fatal "Can't get latest version."
fi

# https://downloads.yuchat.ai/linux/YuChat-6.8.0.rpm
PKGURL="$BASEURL/$PKGNAME-$VERSION.rpm"

install_pkgurl
