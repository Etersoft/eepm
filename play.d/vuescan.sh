#!/bin/sh

DESCRIPTION="VueScan from the official site"

PKGNAME=vuescan

SUPPORTEDARCHES="x86_64 x86 aarch64 armhf"

. $(dirname $0)/common.sh


arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        file="vuex64"
        ;;
    x86)
        file="vuex32"
        ;;
    armhf)
        file="vuea32"
        ;;
    aarch64)
        file="vuea64"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

pkgtype="$(epm print info -p)"

PKGURL="$(eget --list --latest https://www.hamrick.com/alternate-versions.html "$file*.$pkgtype" )"
epm install "$PKGURL"
