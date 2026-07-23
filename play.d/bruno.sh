#!/bin/sh

PKGNAME=bruno
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Bruno - open-source API client"
URL="https://github.com/usebruno/bruno"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"
arch="$(epm print info -a)"

case "$pkgtype" in
    rpm|deb)
        ;;
    *)
        fatal "$(epm print info -e) is not supported (package type is $pkgtype)"
        ;;
esac

case "$arch-$pkgtype" in
    x86_64-rpm)
        pkgarch="x86_64"
        ;;
    x86_64-deb)
        pkgarch="amd64"
        ;;
    aarch64-rpm)
        pkgarch="aarch64"
        ;;
    aarch64-deb)
        pkgarch="arm64"
        ;;
    *)
        fatal "$(epm print info -e) is not supported (arch $arch, package type is $pkgtype)"
        ;;
esac

mask="${PKGNAME}_${VERSION}_${pkgarch}_linux.$pkgtype"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "$mask")
else
    PKGURL="$URL/releases/download/v$VERSION/$mask"
fi

install_pkgurl
