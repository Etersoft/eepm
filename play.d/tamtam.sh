#!/bin/sh

PKGNAME=tamtam-app
SUPPORTEDARCHES="x86_64 x86"
DESCRIPTION="TamTam messenger from the official site"

. $(dirname $0)/common.sh


arch="$(epm print info --debian-arch)"
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
