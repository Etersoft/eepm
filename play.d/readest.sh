#!/bin/sh

PKGNAME=readest
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Modern, feature-rich ebook reader designed for avid readers offering seamless cross-platform access, powerful tools, and an intuitive interface"
URL="https://github.com/readest/readest"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

case $pkgtype in
    rpm)
        pkgformat="rpm"
        arch=$(epm print info -a)
        PKGURL=$(get_github_url https://github.com/readest/readest "Readest-${VERSION}-1.$arch.$pkgformat")
        ;;
    *)
        pkgformat="deb"
        arch=$(epm print info --debian-arch)
        PKGURL=$(get_github_url https://github.com/readest/readest "Readest_${VERSION}_$arch.$pkgformat")
        ;;
esac

install_pkgurl
