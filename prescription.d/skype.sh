#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

[ "$1" != "--run" ] && echo "Install Skype for Linux - Stable/Release Version from the official site" && exit

[ "$(distro_info -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

#arch=$(distro_info --distro-arch)
pkgtype=$(distro_info -p)

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

epm install --repack "$PKG"
