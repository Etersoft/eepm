#!/bin/sh

PKGNAME=coddy
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Coddy Agent - a coding agent harness in one Go binary"
URL="https://coddy.dev/"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

case "$arch" in
    x86_64)
        arch="amd64"
        ;;
    aarch64)
        arch="arm64"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

PKGURL=$(get_github_url "https://github.com/coddy-project/coddy-agent" "coddy_${VERSION}_linux_${arch}.tar.gz")

install_pack_pkgurl
