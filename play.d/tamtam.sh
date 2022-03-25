#!/bin/sh

PKGNAME=tamtam-app
DESCRIPTION="TamTam messenger from the official site"

. $(dirname $0)/common.sh


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
