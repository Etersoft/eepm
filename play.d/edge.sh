#!/bin/sh

BASEPKGNAME=microsoft-edge
SUPPORTEDARCHES="x86_64"
VERSION="$2"
PRODUCTALT="stable beta dev"
DESCRIPTION="Microsoft Edge browser (dev) from the official site"

. $(dirname $0)/common.sh

# epm uses eget to download * names
epm install "https://packages.microsoft.com/repos/edge/pool/main/m/$PKGNAME/${PKGNAME}_${VERSION}_amd64.deb"
