#!/bin/sh

PKGNAME=firefox-nightly
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Firefox nightly from the official site"
URL="https://ftp.mozilla.org/pub/firefox/nightly/latest-mozilla-central/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch=$(epm print info -a)

PKGURL="https://ftp.mozilla.org/pub/firefox/nightly/latest-mozilla-central/firefox-$VERSION.en-US.linux-$arch.deb"

# FIXME: need we fix workaround in epm install ?
[ "$VERSION" = "*" ] && PKGURL="$(eget --list --latest $PKGURL)"

install_pkgurl
