#!/bin/sh

PKGNAME=Kulibin
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Кулибин — приложение цифровой образовательной среды"
URL="https://kulibin.app"

. $(dirname $0)/common.sh

warn_version_is_not_supported
export EPM_REPACK_VERSION="1.0"

PKGURL="https://cdn.kulibin.app/Kulibin-x86-64.AppImage"

install_pkgurl
