#!/bin/sh

PKGNAME=KeyRay
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Keyboard layout auto-switcher (alternative to Punto Switcher) from the official site"
URL="https://www.keyray.ru/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://appcast.keyray.ru/download/latest/linux"

install_pkgurl
