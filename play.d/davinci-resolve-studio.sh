#!/bin/sh

BASEPKGNAME=davinci-resolve-studio
PRODUCTALT="'' beta"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="DaVinci Resolve Studio - professional video editing software from Blackmagic Design"
URL="https://www.blackmagicdesign.com/products/davinciresolve"

BLACKMAGIC_PRODUCT_NAME="DaVinci Resolve Studio"

. $(dirname $0)/common-blackmagic.sh

PKGURL="$(get_blackmagic_pkgurl)" || exit 1

install_pack_pkgurl || exit 1

assure_blackmagic_gpu_dependencies
