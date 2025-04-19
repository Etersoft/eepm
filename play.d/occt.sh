#!/bin/sh

PKGNAME=OCCT
SUPPORTEDARCHES="x86_64"
DESCRIPTION='test and certify your system, ensuring a comprehensive assessment of its stability.'
URL="https://www.ocbase.com/download"

. $(dirname $0)/common.sh

warn_version_is_not_supported

VERSION=$(eget -O- https://www.ocbase.com/download | grep -oP '"versionStr":"\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1)
PKGURL="https://dl.ocbase.com/linux/per/stable/OCCT"

install_pack_pkgurl "$VERSION"
