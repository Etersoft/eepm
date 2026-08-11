#!/bin/sh

PKGNAME=nomachine
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="NoMachine from the official site"
URL="https://www.nomachine.com"

. $(dirname $0)/common.sh

DOWNLOADURL="https://download.nomachine.com/download/?id=43&platform=linux"


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
    # NoMachine removes old package files, so don't use stale app-versions here.
    PKGURL="$(eget -q -O- "$DOWNLOADURL" | grep -o "https://web9001\\.nomachine\\.com/download/[0-9.]*/Linux/nomachine-personal-edition_[0-9.]*_[0-9]*_$arch\\.$pkgtype" | head -n1)"
    [ -n "$PKGURL" ] || fatal "Can't get NoMachine package URL"
    install_pack_pkgurl
    exit
fi

# 9.5.7 -> 9.5
base=$(echo "$VERSION" | sed -e 's|_[0-9]*$||' -e 's|\.[0-9]*$||')

if ! echo "$VERSION" | grep -q '_[0-9]*$' ; then
    # NoMachine package release suffix.
    VERSION="${VERSION}_1"
fi

#mask="$(epm print constructname $PKGNAME "$VERSION*" $arch $pkgtype)"
# https://web9001.nomachine.com/download/10.0/Linux/nomachine-personal-edition_10.0.57_2_x86_64.rpm
PKGURL="https://web9001.nomachine.com/download/$base/Linux/nomachine-personal-edition_${VERSION}_$arch.$pkgtype"

install_pack_pkgurl
