#!/bin/sh

BASEPKGNAME=rupost-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="RuPost Desktop Personal from the official site"
URL="https://www.rupost.ru/desktop"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://www.rupost.ru/desktop/download/linux/"

epm install $PKGURL

