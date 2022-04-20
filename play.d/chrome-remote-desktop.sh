#!/bin/sh

PKGNAME=chrome-remote-desktop
DESCRIPTION='' # echo " Remote desktop support for google-chrome & chromium" && exit

. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

echo "It is not finished yet. Just skipping."
exit 0

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
