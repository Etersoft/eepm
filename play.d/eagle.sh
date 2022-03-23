#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=Autodesk_EAGLE

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "EAGLE (EDA software) from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

VERSION=9.6.2
IPFSHASH=Qmd38jJnTnUMUeJuKSDBGesqXF3SxEahUVZc6NUPyMKgj1
PKGURL="https://trial2.autodesk.com/NET17SWDLD/2017/EGLPRM/ESD/Autodesk_EAGLE_${VERSION}_English_Linux_64bit.tar.gz"

if ! epm install --repack "$PKGURL" ; then
    echo "It is possible you are blocked from USA, trying get from IPFS ..."
    pkgname=$(basename $PKGURL)
    $EGET -O $pkgname http://dhash.ru/ipfs/$IPFSHASH || fatal "Can't get $pkgname from IPFS."
    epm install --repack $pkgname || exit
    rm -fv $pkgname
fi

echo
echo "
Run via
$ eagle
"
