#!/bin/sh

PKGNAME=readest
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Modern, feature-rich ebook reader designed for avid readers offering seamless cross-platform access, powerful tools, and an intuitive interface"
URL="https://github.com/readest/readest"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

case $pkgtype in
    rpm)
        pkgformat="rpm"
        arch=$(epm print info -a)
        ;;
    *)
        pkgformat="deb"
        arch=$(epm print info --debian-arch)
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    case $pkgformat in
        rpm) PKGURL=$(get_github_url "$URL" "Readest-*-*.$arch.$pkgformat") ;;
        *)   PKGURL=$(get_github_url "$URL" "Readest_*_$arch.$pkgformat") ;;
    esac
else
    [ -n "$RELEASE" ] || RELEASE=1
    case $pkgformat in
        rpm) PKGURL="$URL/releases/download/v${VERSION}/Readest-${VERSION}-${RELEASE}.$arch.$pkgformat" ;;
        *)   PKGURL="$URL/releases/download/v${VERSION}/Readest_${VERSION}_$arch.$pkgformat" ;;
    esac
fi

install_pkgurl
