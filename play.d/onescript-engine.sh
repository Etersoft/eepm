#!/bin/sh

PKGNAME=onescript-engine
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="OneScript Engine from the official site"
URL="https://oscript.io/"

. $(dirname $0)/common.sh

warn_version_is_not_supported
VERSION=1.9.3

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGURL="https://oscript.io/downloads/latest/x64/onescript-engine-${VERSION}-1.fc26.noarch.rpm"
        PKGMASK="onescript-engine-*.noarch.rpm"
        ;;
    *)
        PKGURL="https://oscript.io/downloads/latest/x64/onescript-engine_${VERSION}_all.deb"
        PKGMASK="onescript-engine_*_all.deb"
        ;;
esac

#if [ "$VERSION" = "*" ] ; then
    # can't parse from the page
    # PKGURL="$(eget --list --latest https://oscript.io/downloads "$PKGMASK")"
#fi

install_pkgurl
