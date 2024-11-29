#!/bin/sh
PKGNAME=firefox
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Fast and Private Web Browser"
URL="https://www.mozilla.org/en-US/firefox"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ]; then
    VERSION="$(eget -O- https://www.mozilla.org/en-US/firefox/releases/ | \
        grep -oP '[0-9]+\.[0-9]+(\.[0-9]+)?(?=/releasenotes/)' | \
        sort -V | tail -n1)"
fi

# --second-latest because firefox-133.0.tar.bz2.asc
PKGURL="$(eget --list --second-latest https://ftp.mozilla.org/pub/firefox/releases/$VERSION/linux-x86_64/en-US/ "firefox-$VERSION.tar.*")"

install_pack_pkgurl $VERSION
