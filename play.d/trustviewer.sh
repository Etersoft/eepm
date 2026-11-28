#!/bin/sh

PKGNAME=trustviewer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="TrustViewer - free remote access from the official site"
URL="https://trustservice.tech/"

. $(dirname $0)/common.sh

# unversioned download link, the vendor keeps only the current build
warn_version_is_not_supported

PKGURL="https://trustservice.tech/download/trustviewer.tar"

install_pack_pkgurl
