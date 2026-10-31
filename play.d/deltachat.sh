#!/bin/sh

PKGNAME=deltachat-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Delta Chat is a decentralized and secure messenger app"
URL="https://github.com/deltachat/deltachat-desktop"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype=deb
arch=$(epm print info --debian-arch)

# Upstream RPM cannot be unpacked by alien on ALT, use the DEB there.
if [ "$(epm print info -p)" = "rpm" ] && [ "$(epm print info -s)" != "alt" ] ; then
    pkgtype=rpm
    arch=$(epm print info -a)
fi

PKGURL=$(get_github_url "$URL" "deltachat-desktop*$arch.$pkgtype")

install_pkgurl
