#!/bin/sh

PKGNAME=nomachine
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="NoMachine from the official site"
URL="https://www.nomachine.com"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
pkgtype="$(epm print info -p)"
case "$pkgtype" in
    rpm|deb)
        ;;
    *)
        pkgtype="deb"
        ;;
esac

case "$arch-$pkgtype" in
    x86_64-deb)
        arch=amd64
        ;;
    x86-rpm)
        arch=i686
        ;;
    x86-deb)
        arch=i386
        ;;
#    aarch64)
#        arch=arm64
#        ;;
esac

# VERSION=8.16.1
[ "$VERSION" = "*" ] && VERSION="$(eget -O- https://downloads.nomachine.com/ru/download/?id=4 | grep -A1 "Версия:" | tail -n1 | sed -e 's|.*<p>\([0-9.]*\)_1</p>.*|\1|')"

base=$(echo "$VERSION" | sed -e 's|\.[0-9]*$||')

#mask="$(epm print constructname $PKGNAME "$VERSION*" $arch $pkgtype)"
PKGURL="https://download.nomachine.com/download/$base/Linux/nomachine_${VERSION}_1_$arch.$pkgtype"

install_pkgurl

