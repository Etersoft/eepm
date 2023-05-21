#!/bin/sh

PKGNAME=Autodesk_EAGLE
SUPPORTEDARCHES="x86_64"
DESCRIPTION="EAGLE (EDA software) from the official site"

. $(dirname $0)/common.sh


VERSION=9.6.2
IPFSHASH=Qmd38jJnTnUMUeJuKSDBGesqXF3SxEahUVZc6NUPyMKgj1
PKGURL="https://trial2.autodesk.com/NET17SWDLD/2017/EGLPRM/ESD/Autodesk_EAGLE_${VERSION}_English_Linux_64bit.tar.gz"

# use temp dir
PKGDIR="$(mktemp -d)"
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

if ! epm tool eget $PKGURL ; then
    echo "It is possible you are blocked from USA, trying get from IPFS ..."
    pkgname=$(basename $PKGURL)
    epm tool eget -O $pkgname https://dhash.ru/ipfs/$IPFSHASH || fatal "Can't get $pkgname from IPFS."
fi

epm install --repack *.tar.gz || exit

echo
echo "
Run via
$ eagle
"
