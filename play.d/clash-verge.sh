#!/bin/sh

PKGNAME=clash-verge
VERSION="$2"
SUPPORTEDARCHES="x86_64 aarch64"
DESCRIPTION="CClash Verge from the official site"
URL="https://www.clashverge.dev/"

. $(dirname $0)/common.sh

is_openssl_enough 3 || fatal "There is no needed OpenSSL 3 in the system."

arch="$(epm print info --debian-arch)"

#https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v2.2.3/Clash.Verge-2.2.3-1.aarch64.rpm
#https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v2.2.3/Clash.Verge-2.2.3-1.x86_64.rpm
# Clash.Verge_2.2.3_amd64.deb
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/clash-verge-rev/clash-verge-rev/" "Clash.Verge_${VERSION}_$arch.deb")
else
    PKGURL="https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v${VERSION}/Clash.Verge_${VERSION}_$arch.deb"
fi

install_pkgurl
