#!/bin/sh

PKGNAME=rstudio
SUPPORTEDARCHES="x86_64"
DESCRIPTION='RStudio from the official site'

. $(dirname $0)/common.sh

arch=x86_64
pkgtype=rpm

PKGMASK="$(epm print constructname $PKGNAME "*" $arch $pkgtype)"
PKG="$(epm tool eget --list --latest https://www.rstudio.com/products/rstudio/download/ $PKGMASK)" || fatal "Can't get package URL"
[ -n "$PKG" ] || fatal "Can't get package URL"

epm install --repack "$PKG"
