#!/bin/sh

PKGNAME=cuda-z
VERSION="$2"
SUPPORTEDARCHES="x86_64 x86"
DESCRIPTION="CUDA-Z from the official site"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        file="CUDA-Z-$VERSION-64bit.run/download"
        ;;
    x86)
        file="CUDA-Z-$VERSION-32bit.run/download"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

PKGURL="$(eget --list --latest https://cuda-z.sourceforge.net/ "$file" )"

install_pack_pkgurl
