#!/bin/sh

PKGNAME=YouGile
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Система управления проектами и задачами"
URL="https://yougile.com"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_json_value https://dist.yougile.com/app/latest.json version)"
fi

PKGURL="https://dist.yougile.com/app/YouGile-$VERSION-x86_64.AppImage"

install_pkgurl
