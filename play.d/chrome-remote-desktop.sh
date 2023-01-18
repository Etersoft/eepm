#!/bin/sh

PKGNAME=chrome-remote-desktop
SUPPORTEDARCHES="x86_64"
DESCRIPTION='' # echo " Remote desktop support for google-chrome & chromium" && exit

. $(dirname $0)/common.sh


echo "Note: It is not tested yet."

#arch=$($DISTRVENDOR --distro-arch)
#pkgtype=$($DISTRVENDOR -p)
repack=''
arch=amd64
pkgtype=deb

# we have workaround for their postinstall script, so always repack rpm package
[ "$($DISTRVENDOR -p)" = "deb" ] || repack='--repack'

PKG="https://dl.google.com/linux/direct/${PKGNAME}_current_$arch.$pkgtype"

epm install $repack "$PKG" || exit

echo '
You need run
# serv chrome-remote-desktop on
to enable the service'
