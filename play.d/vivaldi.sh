#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=vivaldi-stable

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Vivaldi browser from the official site" && exit

arch="$($DISTRVENDOR --debian-arch)"
case "$arch" in
    amd64|i386|armhf)
        ;;
    *)
        fatal "Debian $arch arch is not supported"
        ;;
esac

# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=vivaldi

# TODO:
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=vivaldi-ffmpeg-codecs

# https://repo.vivaldi.com/archive/rpm/x86_64/

# epm uses eget to download * names
epm install "https://repo.vivaldi.com/archive/deb/pool/main/$(epm print constructname $PKGNAME "*" $arch deb)"
