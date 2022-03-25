#!/bin/sh

PKGNAME=microsoft-edge-dev
DESCRIPTION="Microsoft Edge browser (dev) from the official site"

. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# epm uses eget to download * names
epm install "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-dev/microsoft-edge-*_amd64.deb"
