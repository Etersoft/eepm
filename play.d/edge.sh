#!/bin/sh

BASEPKGNAME=microsoft-edge
SUPPORTEDARCHES="x86_64"
VERSION="$2"
PRODUCTALT="stable beta dev"
DESCRIPTION="Microsoft Edge browser (dev) from the official site"

. $(dirname $0)/common.sh

PKGURL="https://packages.microsoft.com/repos/edge/pool/main/m/$PKGNAME/${PKGNAME}_${VERSION}-[12]_amd64.deb"

install_pkgurl
