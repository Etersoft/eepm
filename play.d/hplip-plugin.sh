#!/bin/sh

PKGNAME=hplip-plugin
SUPPORTEDARCHES="x86_64 x86 armhf aarch64"
VERSION="$2"
DESCRIPTION='Binary plugin for HPs hplip printer driver library'
URL="https://developers.hp.com/hp-linux-imaging-and-printing/binary_plugin.html"

. $(dirname $0)/common.sh

epm installed hplip || fatal "hplip package is not installed"

# for current hplip package
if [ "$VERSION" = "*" ] ; then
    VERSION="$(epm print version for package hplip)"
fi

# https://www.openprinting.org/download/printdriver/auxfiles/HP/plugins/hplip-$VERSION-plugin.run
PKGURL="https://developers.hp.com/sites/default/files/hplip-$VERSION-plugin.run"

install_pack_pkgurl
