#!/bin/sh

PKGNAME=packer
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="A tool for creating identical machine images for multiple platforms from a single source configuration"
URL="https://developer.hashicorp.com/packer"

. $(dirname $0)/common.sh

BASEURL="https://hashicorp-releases.yandexcloud.net/packer"
arch="$(epm print info --debian-arch)"

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- "$BASEURL/" 2>/dev/null | grep -o 'packer/[0-9][0-9.]*' | head -1 | sed 's|packer/||')
    [ -n "$VERSION" ] || fatal "Can't get latest version"
fi

PKGURL="$BASEURL/${VERSION}/packer_${VERSION}_linux_${arch}.zip"

install_pack_pkgurl
