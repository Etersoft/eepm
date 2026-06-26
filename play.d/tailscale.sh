#!/bin/sh

PKGNAME=tailscale
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="The easiest, most secure way to use WireGuard and 2FA"
URL="https://tailscale.com/"

. $(dirname $0)/common.sh

rpmarch="$(epm print info -a)"
repo_url="https://pkgs.tailscale.com/stable/fedora/$rpmarch"

VERSION="${VERSION#v}"
[ "$VERSION" = "*" ] && VERSION='[0-9][^_]*'

file="$(get_rpm_repo_latest_file "$repo_url" "tailscale_${VERSION}_${rpmarch}.rpm")"
[ -n "$file" ] || fatal "Can't find tailscale package"

PKGURL="$repo_url/$file"

install_pkgurl
