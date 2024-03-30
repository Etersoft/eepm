#!/bin/sh

DESCRIPTION="VueScan from the official site"

PKGNAME=vuescan

SUPPORTEDARCHES="x86_64 x86 aarch64 armhf"
VERSION="$2"

. $(dirname $0)/common.sh

warn_version_is_not_supported

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
