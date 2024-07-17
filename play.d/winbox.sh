#!/bin/sh

PKGNAME=winbox
SUPPORTEDARCHES="x86_64"
VERSION="3.40"
DESCRIPTION='Winbox from the official site'
URL="https://mikrotik.com/download"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://mt.lv/winbox64"

install_pack_pkgurl $VERSION
