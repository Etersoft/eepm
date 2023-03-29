#!/bin/sh

DESCRIPTION="CUDA-Z from the official site"

PKGNAME=cuda-z

SUPPORTEDARCHES="x86_64 x86"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        file="CUDA-Z-*-64bit.run/download"
        ;;
    x86)
        file="CUDA-Z-*-32bit.run/download"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

pkgtype="$(epm print info -p)"

PKGURL="$(eget --list --latest https://cuda-z.sourceforge.net/ "$file" )"
epm pack --install $PKGNAME "$PKGURL"
