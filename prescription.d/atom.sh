#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=atom-beta

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "The hackable text editor from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

#arch=$($DISTRVENDOR --distro-arch)
#pkgtype=$($DISTRVENDOR -p)
arch=amd64
pkgtype=deb

PKG=$($EGET --list --latest https://github.com/atom/atom/releases/ "atom-$arch.$pkgtype") || fatal "Can't get package URL"

epm install "$PKG"
