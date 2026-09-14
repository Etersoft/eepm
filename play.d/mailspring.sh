#!/bin/sh

PKGNAME=mailspring
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Mailspring - a beautiful, fast and fully open source mail client"
URL="https://www.getmailspring.com/"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"
case "$pkgtype" in
    rpm)
        arch="$(epm print info -a)"
        mask="$PKGNAME-$VERSION-*.$arch.rpm"
        ;;
    *)
        arch="$(epm print info --debian-arch)"
        mask="$PKGNAME-$VERSION-$arch.deb"
        ;;
esac

PKGURL=$(get_github_url https://github.com/Foundry376/Mailspring/ "$mask")

install_pkgurl
