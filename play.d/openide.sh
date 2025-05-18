#!/bin/sh

PKGNAME=openIDE
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="openIDE - Free IDE based on IntelliJ IDEA Community Edition"
URL="https://openide.ru/"

. $(dirname $0)/common.sh

arch=$(epm print info -a)
case "$arch" in
    x86_64)
        arch=""
        ;;
    arm64 | aarch64)
        arch="-aarch64"
        ;;
esac

if [ "$VERSION" = "*" ]; then
    # stable version
    VERSION="$(eget -q -O- https://openide.ru/download/ | grep "Сборка:" | sed -e "s|.*Сборка:</span>[[:space:]]||" -e "s|</p>.*||")"
    if [ -z "$VERSION" ] ; then
        # latest may be unstable
        VERSION="$(eget -q -O- https://download.openide.ru/ | grep -B1 "openIDE.*tar\.gz" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" | tail -n1)"
    fi
fi

PKGURL="https://download.openide.ru/$VERSION/openIDE-$VERSION${arch}.tar.gz"

install_pkgurl
