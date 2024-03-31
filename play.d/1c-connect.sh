#!/bin/sh

PKGNAME=1c-connect
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="1C Connect — Service & Help desk со встроенным удалённым доступом и мессенджером"
URL="https://1c-connect.com"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://updates.1c-connect.com/desktop/distribs/1C-Connect-Linux-x64.tar.gz"

install_pack_pkgurl
