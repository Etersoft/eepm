#!/bin/sh

PKGNAME=equibop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Custom Discord App aiming to give you better performance and improve linux support '
URL="https://github.com/Equicord/Equibop"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

case $pkgtype in
    deb)
        arch="$(epm print info --debian-arch)"
        pkgname="equibop_${VERSION}_$arch.deb"
        ;;
    *)
        arch="$(epm print info -a)"
        pkgname="equibop-${VERSION}.$arch.rpm"
        ;;
esac

PKGURL=$(get_github_url "$URL" "$pkgname")

install_pkgurl

