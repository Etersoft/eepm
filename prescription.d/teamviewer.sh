#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

[ "$1" != "--run" ] && echo "Install Teamviewer from the official site" && exit

PKGNAME="teamviewer"

arch="$(distro_info -a)"
case "$arch" in
    x86_64|x86)
        ;;
    armhf)
        PKGNAME="teamviewer-host"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

# See https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=teamviewer

# epm uses eget to download * names
epm --noscripts --repack install "https://download.teamviewer.com/download/linux/$(epm print constructname $PKGNAME)"
