#!/bin/sh

PKGNAME=microsoft-edge-dev
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Microsoft Edge browser (dev) from the official site"

. $(dirname $0)/common.sh



# epm uses eget to download * names
epm install "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-dev/microsoft-edge-*_amd64.deb"
