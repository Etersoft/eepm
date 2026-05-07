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
    VERSION="$(eget -q -O- 'https://download.nomachine.com/download/?id=1&platform=linux' | grep -o "nomachine_[0-9.]*_[0-9]*_$arch\\.$pkgtype" | head -n1 | sed -e "s|nomachine_||" -e "s|_$arch\\.$pkgtype||")"
    [ -n "$VERSION" ] || fatal "Can't get version"
fi

# 9.5.7 -> 9.5
base=$(echo "$VERSION" | sed -e 's|_[0-9]*$||' -e 's|\.[0-9]*$||')

if ! echo "$VERSION" | grep -q '_[0-9]*$' ; then
    # NoMachine package release suffix.
    VERSION="${VERSION}_1"
fi

#mask="$(epm print constructname $PKGNAME "$VERSION*" $arch $pkgtype)"
# https://web9001.nomachine.com/download/9.5/Linux/nomachine_9.5.7_2_x86_64.rpm
PKGURL="https://web9001.nomachine.com/download/$base/Linux/nomachine_${VERSION}_$arch.$pkgtype"

install_pkgurl
