#!/bin/sh

PKGNAME=fvm
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Flutter Version Management: A simple CLI to manage Flutter SDK versions"
URL="https://fvm.app/"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch="x64" ;;
    aarch64)
        arch="arm64" ;;
esac

PKGURL="$(get_github_url https://github.com/leoafarias/fvm "fvm-${VERSION}-linux-${arch}.tar.gz")"

install_pack_pkgurl
