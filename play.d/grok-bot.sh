#!/bin/sh

PKGNAME=grok-bot
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Grok Bot - desktop agent from xAI"
URL="https://x.ai/bot"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"
REPO="https://downloads.cursor.com/aptrepo"

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_deb_repo_latest_version "$REPO/dists/grok-bot/main/binary-$arch/Packages.gz" $PKGNAME)"
    [ -n "$VERSION" ] || fatal "Can't get latest version of $PKGNAME"
fi

PKGURL="$REPO/pool/grok-bot/g/gr/${PKGNAME}_${VERSION}_$arch.deb"

install_pkgurl
