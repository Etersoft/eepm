#!/bin/sh

PKGNAME=YouGile
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Система управления проектами и задачами"
URL="https://yougile.com"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(eget -O- https://dist.yougile.com/app/latest.json | grep -o '"version":[^,}]*' | sed 's/[^0-9.]//g')"
fi

PKGURL="https://dist.yougile.com/app/YouGile-$VERSION-x86_64.AppImage"

install_pkgurl
