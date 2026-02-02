#!/bin/sh

PKGNAME=mailspring
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Mailspring - a beautiful, fast and fully open source mail client"
URL="https://www.getmailspring.com/"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"
case "$pkgtype" in
    rpm)
        PKGURL=$(get_github_url https://github.com/Foundry376/Mailspring/ "$PKGNAME.*$VERSION.*$arch.$pkgtype")
        ;;
    *)
        PKGURL=$(get_github_url https://github.com/Foundry376/Mailspring/ "$PKGNAME.*$VERSION.*$arch.deb")
        ;;
esac

install_pkgurl
