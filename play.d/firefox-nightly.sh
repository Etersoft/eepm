#!/bin/sh

PKGNAME=firefox-nightly
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Firefox nightly from the official site"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch=x86_64

VERSION="*"
PKGURL="https://ftp.mozilla.org/pub/firefox/nightly/latest-mozilla-central/firefox-$VERSION.en-US.linux-$arch.deb"

install_pkgurl
