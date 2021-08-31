#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=tamtam-app

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "TamTam messenger from the official site" && exit

arch="$($DISTRVENDOR --debian-arch)"
case "$arch" in
    amd64)
        ;;
    i386)
        arch=i686
        ;;
    *)
        fatal "Debian $arch arch is not supported"
        ;;
esac

# epm uses eget to download * names
epm install "https://download.tamtam.chat/latest/TamTam-$arch.deb"
