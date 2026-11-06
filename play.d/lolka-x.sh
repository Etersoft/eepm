#!/bin/sh

PKGNAME=lolka-x
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Lolka X — новый клиент платформы для общения Lolka (бета)'
URL="https://lolka.app/download/linux"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_json_value https://updates.lolka.app/desktop/linux/latest version)"
fi

[ -n "$VERSION" ] || fatal "Can't get Lolka X version"

if [ "$(epm print info -p)" = "rpm" ] ; then
    PKGURL="https://cdn.lolka.app/desktop/linux/$VERSION/lolka-x-$VERSION.x86_64.rpm"
else
    PKGURL="https://cdn.lolka.app/desktop/linux/$VERSION/lolka-x_${VERSION}_amd64.deb"
fi

install_pkgurl
