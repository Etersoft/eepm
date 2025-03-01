#!/bin/sh

PKGNAME=netbird
SUPPORTEDARCHES="x86_64 aarch64 i386 armv6l"
VERSION="$2"
DESCRIPTION="Secure WireGuard® overlay network with SSO/MFA."
URL="https://github.com/netbirdio/netbird"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
x86_64)
    arch="amd64"
    ;;
aarch64)
    arch="arm64"
    ;;
i386 | i686)
    arch="386"
    ;;
armv6l | armv7l)
    arch="armv6"
    ;;
*)
    fatal "Unsupported architecture: $arch"
    ;;
esac

if [ "$VERSION" = "*" ]; then
    VERSION="$(get_github_tag https://github.com/netbirdio/netbird/)"
fi

PKGURL="https://github.com/netbirdio/netbird/releases/download/v${VERSION}/netbird_${VERSION}_linux_${arch}.deb"

install_pkgurl
