#!/bin/sh

PKGNAME=cnrdrvcups-ufr2-uk
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Canon UFR II Printer Driver for Linux from the official site"
URL="https://www.canon.ru/support/business-product-support/office_driver_guide/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=cnrdrvcups-lb
PKGURL="https://pdisp01.c-wss.com/gdl/WWUFORedirectTarget.do?id=MDEwMDAwOTI0MDQy&cmp=ACB&lang=EN"

install_pack_pkgurl
