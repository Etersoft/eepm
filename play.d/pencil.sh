#!/bin/sh

PKGNAME=Pencil
REPOPKGNAME=pencil
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="Pencil from the official site"
URL="https://pencil.evolus.vn/"

. $(dirname $0)/common.sh

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

# current links:
# https://pencil.evolus.vn/dl/V3.1.1.ga/Pencil-3.1.1.ga.x86_64.rpm
# https://pencil.evolus.vn/dl/V3.1.1.ga/Pencil-3.1.1.ga.i686.rpm
# https://pencil.evolus.vn/dl/V3.1.1.ga/Pencil_3.1.1.ga_amd64.deb
# https://pencil.evolus.vn/dl/V3.1.1.ga/Pencil_3.1.1.ga_i386.deb

mask="$(epm print constructname $PKGNAME "$VERSION.ga" $arch)"

PKGURL="$(eget --list --latest https://pencil.evolus.vn/Downloads.html "$mask")" || fatal "Can't get package URL"

install_pkgurl
