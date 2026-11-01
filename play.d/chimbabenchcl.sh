#!/bin/sh

PKGNAME=chimbabenchcl
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="ChimbaBenchCL - OpenCL benchmark for CPU and GPU"
URL="https://github.com/Shedou/ChimbaBenchCL"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "ChimbaBenchCL-v*-Win-Lin-FBSD.zip")"
else
    # https://github.com/Shedou/ChimbaBenchCL/releases/download/CBCL_12/ChimbaBenchCL-v1.2-Win-Lin-FBSD.zip
    PKGURL="$URL/releases/download/CBCL_$(echo "$VERSION" | tr -d .)/ChimbaBenchCL-v$VERSION-Win-Lin-FBSD.zip"
fi

install_pack_pkgurl
