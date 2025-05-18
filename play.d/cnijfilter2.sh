#!/bin/sh

PKGNAME=cnijfilter2
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="IJ Printer Driver for Linux from the official site"
URL="https://www.canon-europe.com/support/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=cnrdrvcups-lb
#PKGURL="https://gdlp01.c-wss.com/gds/0/0100010920/01/cnijfilter2-6.10-1-rpm.tar.gz"
PKGURL="https://gdlp01.c-wss.com/gds/1/0100012301/02/cnijfilter2-6.80-1-rpm.tar.gz"

install_pack_pkgurl
