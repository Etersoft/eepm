#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=chrome-remote-desktop

if [ "$1" = "--remove" ] ; then
    epm remove chrome-remote-desktop
    exit
fi

[ "$1" != "--run" ] && echo "Install  Remote desktop support for google-chrome & chromium" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

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
