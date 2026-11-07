#!/bin/sh

PKGNAME=crush
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="A powerful terminal-based AI assistant for developers"
URL="https://github.com/charmbracelet/crush"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        RPMARCH="x86_64"
        DEBARCH="amd64"
        ;;
    aarch64)
        RPMARCH="aarch64"
        DEBARCH="arm64"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

pkgtype=$(epm print info -p)
case "$pkgtype" in
    rpm)
        mask="crush-${VERSION}-*.${RPMARCH}.rpm"
        ;;
    *)
        mask="crush_${VERSION}_${DEBARCH}.deb"
        ;;
esac

if [ "$VERSION" = "*" ] || [ "$pkgtype" = "rpm" ] ; then
    PKGURL=$(get_github_url "$URL" "$mask")
else
    PKGURL="$URL/releases/download/v${VERSION}/$mask"
fi

install_pkgurl
