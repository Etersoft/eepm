#!/bin/sh

PKGNAME=firefox-nightly
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Firefox nightly from the official site"
URL="https://ftp.mozilla.org/pub/firefox/nightly/latest-mozilla-central/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch=$(epm print info -a)

# eget --list returns doubled path for this FTP (absolute hrefs), extract filename
# always fetch latest since nightly builds change daily and old ones are not kept
PKGURL="$URL$(eget --list --latest "${URL}firefox-*.en-US.linux-$arch.deb" | sed 's|.*/||')"

install_pkgurl
