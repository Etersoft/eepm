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

[ "$1" != "--run" ] && echo "Install EAGLE (EDA software) from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

VERSION=9.6.2
PKGURL="https://trial2.autodesk.com/NET17SWDLD/2017/EGLPRM/ESD/Autodesk_EAGLE_${VERSION}_English_Linux_64bit.tar.gz"

epm install --repack "$PKGURL"

echo
echo "
Run via
$ eagle
"
