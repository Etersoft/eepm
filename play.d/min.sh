#!/bin/sh

PKGNAME=min
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="A fast, minimal browser that protects your privacy"
URL="https://github.com/minbrowser/min"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
x86_64)
    file="min-${VERSION}-amd64.deb"
    ;;
aarch64)
    file="min-${VERSION}-arm64.deb"
    ;;
armhf)
    file="min-${VERSION}-armv7l.deb"
    ;;
*)
    fatal "$arch arch is not supported"
    ;;
esac

PKGURL="$(eget --list --latest "${URL}"/releases "${file}")"

install_pkgurl
