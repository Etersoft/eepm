#!/bin/sh

PKGNAME=Cherry-Studio
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Cherry Studio - AI productivity studio with smart chat, autonomous agents, and 300+ assistants"
URL="https://github.com/CherryHQ/cherry-studio"

. $(dirname $0)/common.sh

export EPM_REPACK_SCRIPT=Cherry-Studio
export EEPM_INTERNAL_PKGNAME="$PKGNAME CherryStudio"

arch="$(epm print info -a)"

case "$arch" in
    x86_64)
        ARCH="x86_64"
        DEBARCH="amd64"
        ;;
    aarch64)
        ARCH="aarch64"
        DEBARCH="arm64"
        ;;
esac

case $(epm print info -p) in
    rpm)
        mask="$PKGNAME-$VERSION-$ARCH.rpm"
        ;;
    *)
        mask="$PKGNAME-$VERSION-$DEBARCH.deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "$mask")"
else
    PKGURL="$URL/releases/download/v$VERSION/$mask"
fi

install_pkgurl
