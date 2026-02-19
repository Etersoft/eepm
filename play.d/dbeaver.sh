#!/bin/sh

PKGNAME=dbeaver-ce
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="DBeaver Community from the official site"
URL="https://dbeaver.io/"

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGURL="https://dbeaver.io/files/$VERSION/dbeaver-ce-$VERSION-linux-x86_64.rpm"
        [ "$VERSION" = "*" ] && PKGURL="https://dbeaver.io/files/dbeaver-ce-latest-linux-x86_64.rpm"
        ;;
    *)
        PKGURL="https://dbeaver.io/files/$VERSION/dbeaver-ce-$VERSION-linux-x86_64.deb"
        [ "$VERSION" = "*" ] && PKGURL="https://dbeaver.io/files/dbeaver-ce-latest-linux-x86_64.deb"
        ;;
esac

install_pkgurl
