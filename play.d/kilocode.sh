#!/bin/sh

PKGNAME=kilocode
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Kilo Code is an open-source agentic coding platform and CLI tool"
URL="https://github.com/Kilo-Org/kilocode"

. $(dirname $0)/common.sh

case "$(epm print info -a)" in
    x86_64)
        arch=x64
        ;;
    aarch64)
        arch=arm64
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "kilo-linux-${arch}.tar.gz")
else
    PKGURL="$URL/releases/download/v${VERSION}/kilo-linux-${arch}.tar.gz"
fi

install_pack_pkgurl
