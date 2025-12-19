#!/bin/sh

PKGNAME=virtualbox
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="VirtualBox from the official site"
URL="https://www.virtualbox.org"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(fetch_url "https://download.virtualbox.org/virtualbox/LATEST.TXT")" || fatal "Can't get version"
    VERSION="$(echo "$VERSION" | tr -d '[:space:]')"
fi

BASEURL="https://download.virtualbox.org/virtualbox/$VERSION"

# VirtualBox-7.2.4-170995-Linux_amd64.run
PKGURL="$(eget --list --latest "$BASEURL/" "VirtualBox-${VERSION}-*-Linux_amd64.run")"

[ -n "$PKGURL" ] || fatal "Can't get package URL"

install_pack_pkgurl

echo
echo "Note: Add needed users to vboxusers group via # usermod -a -G vboxusers <user>"
