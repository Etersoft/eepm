#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=skypeforlinux

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Install Skype for Linux - Stable/Release Version from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

#arch=$($DISTRVENDOR --distro-arch)
#pkgtype=$($DISTRVENDOR -p)
pkgtype=deb

# don't used
complex_get()
{
    pkgtype=deb
    # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=skypeforlinux-stable-bin
    _pkgname=skypeforlinux
    pkgver=8.65.0.78
    PKG= "https://repo.skype.com/deb/pool/main/s/${_pkgname}/${_pkgname}_${pkgver}_amd64.deb"
}

PKG="https://repo.skype.com/latest/skypeforlinux-64.$pkgtype"

epm install "$PKG"
