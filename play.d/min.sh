#!/bin/sh

PKGNAME=min
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="A fast, minimal browser that protects your privacy"
URL="https://github.com/minbrowser/min"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"

file="min-${VERSION}-${arch}.deb"

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest "https://github.com/minbrowser/min/releases" "$file")"
else
    PKGURL="https://github.com/minbrowser/min/releases/download/v${VERSION}/${file}"
fi

install_pkgurl
