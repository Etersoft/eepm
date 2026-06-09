#!/bin/sh

PKGNAME=tailscale
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="The easiest, most secure way to use WireGuard and 2FA"
URL="https://tailscale.com/"

. $(dirname $0)/common.sh

rpmarch="$(epm print info -a)"
repo_url="https://pkgs.tailscale.com/stable/fedora/$rpmarch"

primary_href="$(fetch_url "$repo_url/repodata/repomd.xml" | sed -n 's|.*href="\([^"]*primary\.xml\.gz\)".*|\1|p' | head -n 1)"
[ -n "$primary_href" ] || fatal "Can't get repository metadata"

VERSION="${VERSION#v}"
[ "$VERSION" = "*" ] && VERSION='[0-9][^_]*'

mask="tailscale_${VERSION}_${rpmarch}.rpm"
file="$(fetch_url "$repo_url/$primary_href" | gzip -d | sed -n "s|.*<location href=\"\($mask\)\".*|\1|p" | sort -V | tail -n 1)"

[ -n "$file" ] || fatal "Can't find tailscale package"

PKGURL="$repo_url/$file"

install_pkgurl
