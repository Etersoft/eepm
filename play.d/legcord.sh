#!/bin/sh

PKGNAME=legcord
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Legcord - lightweight custom Discord client"
URL="https://github.com/Legcord/Legcord"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

case "$pkgtype" in
    rpm)
        arch="$(epm print info -a)"
        ;;
    *)
        pkgtype=deb
        arch="$(epm print info --debian-arch)"
        ;;
esac

PKGURL="$(get_github_url "$URL" "Legcord-${VERSION}-linux-${arch}.${pkgtype}")"

install_pkgurl
