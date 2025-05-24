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

if [ "$VERSION" = "*" ] ; then
    #VERSION="$(eget -O- https://downloads.nomachine.com/download/?id=4 | grep -A1 "Version:" | tail -n1 | sed -e 's|.*<p>\([0-9.]*\)_1</p>.*|\1|')"
    # it is hard to get the page with version
    VERSION=9.0.188
    [ -n "$VERSION" ] || fatal "Can't get version"
fi
base=$(echo "$VERSION" | sed -e 's|\.[0-9]*$||')

# hack for 9.x
VERSION="${VERSION}_11"

#mask="$(epm print constructname $PKGNAME "$VERSION*" $arch $pkgtype)"
PKGURL="https://download.nomachine.com/download/$base/Linux/nomachine_${VERSION}_$arch.$pkgtype"

install_pkgurl

