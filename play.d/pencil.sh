#!/bin/sh

PKGNAME=Pencil
SUPPORTEDARCHES="x86_64 x86"
DESCRIPTION="Pencil from the official site"
URL="https://pencil.evolus.vn/"

. $(dirname $0)/common.sh

is_repacked_package pencil || exit 0

arch=$(epm print info --distro-arch)
case $arch in
    x86_64|amd64)
        arch=$arch ;;
    i686|i386)
        arch=$arch ;;
    i586)
        arch=i686 ;;
    *)
        fatal "Unsupported arch $arch for $(epm print info -d)"
esac

# we have workaround for their postinstall script, so always repack rpm package
repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

# current links:
# https://pencil.evolus.vn/dl/V3.1.1.ga/Pencil-3.1.1.ga.x86_64.rpm
# https://pencil.evolus.vn/dl/V3.1.1.ga/Pencil-3.1.1.ga.i686.rpm
# https://pencil.evolus.vn/dl/V3.1.1.ga/Pencil_3.1.1.ga_amd64.deb
# https://pencil.evolus.vn/dl/V3.1.1.ga/Pencil_3.1.1.ga_i386.deb

PKGMASK="$(epm print constructname $PKGNAME "*.ga" $arch)"

PKGURL="$(epm tool eget --list --latest https://pencil.evolus.vn/Downloads.html $PKGMASK)" || fatal "Can't get package URL"
epm $repack install "$PKGURL"
