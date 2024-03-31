#!/bin/sh

PKGNAME=Autodesk_EAGLE
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="EAGLE (EDA software) from the official site"

. $(dirname $0)/common.sh

warn_version_is_not_supported

VERSION=9.6.2
PKGURL="https://trial2.autodesk.com/NET17SWDLD/2017/EGLPRM/ESD/Autodesk_EAGLE_${VERSION}_English_Linux_64bit.tar.gz"
IPFSURL="ipfs://Qmd38jJnTnUMUeJuKSDBGesqXF3SxEahUVZc6NUPyMKgj1?filename=Autodesk_EAGLE_9.6.2_English_Linux_64bit.tar.gz"

if ! eget --check-site $PKGURL ; then
    echo "It is possible you are blocked from USA, trying via IPFS ..."
    PKGURL="$IPFSURL"
fi

install_pkgurl
