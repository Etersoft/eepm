#!/bin/sh

PKGNAME=mattermost-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Mattermost Desktop application for Linux from the official site"
URL="https://mattermost.com/"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=amd64
        ;;
    aarch64)
        arch=arm64
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

PKGURL=$(eget --list --latest https://github.com/mattermost/desktop/releases $(epm print constructname $PKGNAME "$VERSION*" $arch "deb")) || fatal "Can't get package URL"

install_pkgurl

