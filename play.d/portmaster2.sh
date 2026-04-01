#!/bin/sh

PKGNAME=portmaster2
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Portmaster v2 - Privacy Suite and Application Firewall from the official site"
URL="https://safing.io/portmaster"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://updates.safing.io/latest/linux_amd64/packages/portmaster-installer.deb"

install_pack_pkgurl
