#!/bin/sh

PKGNAME=v2rayN
SUPPORTEDARCHES="x86_64 arm64"
VERSION="$2"
DESCRIPTION="A GUI client for Windows, Linux and macOS, support Xray core and sing-box-core and others"
URL="https://github.com/2dust/v2rayN"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch="64"
        ;;
    arm64|aarch64)
        arch="arm64"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

if [ "$VERSION" = "*" ]; then
    VERSION="$(get_github_tag "https://github.com/2dust/v2rayN/")"
fi

PKGURL="https://github.com/2dust/v2rayN/releases/download/$VERSION/v2rayN-linux-$arch.deb"

install_pkgurl
