#!/bin/sh

PKGNAME=ntfy
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Send push notifications to your phone or desktop via PUT/POST"
URL="https://github.com/binwiederhier/ntfy"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch="amd64"
        ;;
    aarch64)
        arch="arm64"
        ;;
    armhf)
        arch="armv7"
        ;;
esac

pkgtype="$(epm print info -p)"
case "$pkgtype" in
    rpm|deb)
        ;;
    *)
        pkgtype="deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "ntfy_*_linux_${arch}.${pkgtype}")
else
    PKGURL="https://github.com/binwiederhier/ntfy/releases/download/v${VERSION}/ntfy_${VERSION}_linux_${arch}.${pkgtype}"
fi

install_pkgurl
