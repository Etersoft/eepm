#!/bin/sh

PKGNAME=Pinokio
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Pinokio - AI browser to install, run, and automate AI apps"
URL="https://github.com/pinokiocomputer/pinokio"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

# Upstream rpm/deb packages currently have packaging bugs, use AppImage repacking.
case "$arch" in
    x86_64)
        suffix=
        ;;
    aarch64)
        suffix="-arm64"
        ;;
    *)
        fatal "$arch arch is not supported."
        ;;
esac

if [ -n "$VERSION" ] && [ "$VERSION" != "*" ] ; then
    PKGURL="$URL/releases/download/v$VERSION/Pinokio-$VERSION$suffix.AppImage"
else
    info="$(get_github_release_info "$URL" latest)" || fatal "GitHub repository $URL not found or unreachable"
    pattern="/Pinokio-[0-9][0-9.]*$suffix"'\.AppImage$'
    PKGURL="$(echo "$info" | __get_github_download_urls | grep -E "$pattern" | head -n1)"
fi

install_pkgurl
