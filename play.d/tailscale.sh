#!/bin/sh

PKGNAME=tailscale
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="The easiest, most secure way to use WireGuard and 2FA"
URL="https://tailscale.com/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(get_github_tag tailscale/tailscale)
fi

PKGURL="https://pkgs.tailscale.com/stable/fedora/x86_64/tailscale_${VERSION}_x86_64.rpm"

install_pkgurl
