#!/bin/sh

PKGNAME=cnrdrvcups-ufr2-uk
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Canon UFR II Printer Driver for Linux from the official site"
URL="https://www.canon.ru/support/business-product-support/office_driver_guide/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=cnrdrvcups-lb
PKGURL="https://gdlp01.c-wss.com/gds/8/0100007658/33/linux-UFRII-drv-v570-m17n-11.tar.gz"

epm pack --install $PKGNAME "$PKGURL"
