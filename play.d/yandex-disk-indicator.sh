#!/bin/sh

PKGNAME=yandex-disk-indicator
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Panel indicator (GUI) for YandexDisk CLI client for Linux"
URL="https://github.com/slytomcat/yandex-disk-indicator"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # Get latest version from vendor
    VERSION="$(get_github_tag https://github.com/slytomcat/yandex-disk-indicator)"
fi

PKGURL="https://github.com/slytomcat/yandex-disk-indicator/archive/$VERSION.tar.gz"

install_pack_pkgurl
