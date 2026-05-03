#!/bin/sh

PKGNAME=pantum-r
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="CUPS and SANE drivers for new Pantum series (cm2100, kanas_r, mx910de_r)"
URL="https://www.pantum.ru/service-and-support/driver/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# 1.0.17-1astra1
PKGURL="https://www.pantum.ru/wp-content/uploads/2025/06/pantum-r_1.0.17-1astra1_amd64.deb_.zip"

install_pack_pkgurl
