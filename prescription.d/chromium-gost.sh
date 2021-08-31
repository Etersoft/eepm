#!/bin/sh -x

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=chromium-gost

if [ "$1" = "--remove" ] ; then
    # $PKGNAME-stable really
    epm remove $(epmqp $PKGNAME)
    exit
fi

[ "$1" != "--run" ] && echo "Chromium with GOST support from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

#arch=$($DISTRVENDOR --distro-arch)
#pkgtype=$($DISTRVENDOR -p)
arch=amd64
pkgtype=deb

PKG=$($EGET --list --latest https://github.com/deemru/chromium-gost/releases "$PKGNAME-*linux-$arch.$pkgtype") || fatal "Can't get package URL"

epm install "$PKG"
