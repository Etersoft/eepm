#!/bin/sh

PKGNAME=chrome-remote-desktop
SUPPORTEDARCHES="x86_64"
DESCRIPTION='' # echo " Remote desktop support for google-chrome & chromium" && exit

. $(dirname $0)/common.sh


echo "Note: It is not tested yet."

#arch=$(epm print info --distro-arch)
arch=amd64
pkgtype=deb

PKGURL="https://dl.google.com/linux/direct/${PKGNAME}_current_$arch.$pkgtype"

install_pkgurl

echo '
You need run
# serv chrome-remote-desktop on
to enable the service'
