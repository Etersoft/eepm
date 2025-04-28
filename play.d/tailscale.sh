#!/bin/sh

PKGNAME=tailscale
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="The easiest, most secure way to use WireGuard and 2FA"
URL="https://tailscale.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(eget --list --latest "https://dl.fedoraproject.org/pub/fedora/linux/releases/42/Everything/x86_64/os/Packages/t/" "tailscale*.rpm")

install_pkgurl
