#!/bin/sh

PKGNAME=netbird
SUPPORTEDARCHES="x86_64 aarch64 x86 armv6l"
VERSION="$2"
DESCRIPTION="Secure WireGuard® overlay network with SSO/MFA."
URL="https://github.com/netbirdio/netbird"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"
case "$arch" in
i386)
    arch="386"
    ;;
armv6l | armv7l)
    arch="armv6"
    ;;
esac

if [ "$VERSION" = "*" ]; then
    VERSION="$(get_github_tag https://github.com/netbirdio/netbird/)"
fi

PKGURL="https://github.com/netbirdio/netbird/releases/download/v${VERSION}/netbird_${VERSION}_linux_${arch}.deb"

install_pkgurl
