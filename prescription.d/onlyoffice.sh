#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=onlyoffice-desktopeditors

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "ONLYOFFICE for Linux from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

#arch=$($DISTRVENDOR --distro-arch)
arch=amd64
#pkgtype=$($DISTRVENDOR -p)
pkgtype=deb

PKG="https://download.onlyoffice.com/install/desktop/editors/linux/$(epm print constructname $PKGNAME "" $arch deb)"

epm install "$PKG"
