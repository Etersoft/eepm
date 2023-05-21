#!/bin/sh

PKGNAME=geogebra-classic
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="Geogebra 6 from the official site"

. $(dirname $0)/common.sh

arch=$(epm print info --distro-arch)
case $arch in
    x86_64|amd64)
        arch=$arch ;;
    i686|i586|i386)
        arch=i386 ;;
    *)
        fatal "Unsupported arch $arch for $(epm print info -d)"
esac

pkgtype="$(epm print info -p)"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

case $pkgtype in
    deb)
        epm install "https://www.geogebra.net/linux/pool/main/g/geogebra-classic/$(epm print constructname $PKGNAME "$VERSION" $arch)"
        ;;
    rpm)
        epm $repack install "https://www.geogebra.net/linux/rpm/$arch/$(epm print constructname $PKGNAME "$VERSION" $arch)"
        ;;
    *)
        fatal "Unsupported $pkgtype"
        ;;
esac

