#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=geogebra

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Geogebra 6 from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# See also 

arch=x86_64
pkgtype=rpm
pkgver="6.0.666.0"
pkgrel="202109211234"

epm install "http://www.geogebra.net/linux/rpm/x86_64/$PKGNAME-classic-$pkgver-$pkgrel.$arch.$pkgtype"

echo
echo '
fix for running application: "chmod 4755 /usr/share/geogebra-classic/chrome-sandbox"
'
chmod 4755 /usr/share/geogebra-classic/chrome-sandbox

echo
echo '
Geogebra 6 successfully installed.
'
