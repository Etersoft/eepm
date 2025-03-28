#!/bin/sh

PKGNAME=headscale
SUPPORTEDARCHES="x86_64 aarch64 armhf i586"
VERSION="$2"
DESCRIPTION="An open source, self-hosted implementation of the Tailscale control server"
URL="https://github.com/juanfont/headscale"

. $(dirname $0)/common.sh

case "$(epm print info -a)" in
    x86_64)
        arch="amd64" ;;
    aarch64)
        arch="arm64" ;;
    armhf)
        arch="armv7l" ;;
    i586)
        arch="386" ;;
esac


if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/juanfont/headscale/" "${PKGNAME}_.${VERSION}_linux_$arch.deb")
else
    PKGURL="https://github.com/juanfont/headscale/releases/download/v$VERSION/${PKGNAME}_${VERSION}_linux_$arch.deb"
fi

install_pkgurl

