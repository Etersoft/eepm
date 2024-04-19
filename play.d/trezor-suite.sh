#!/bin/sh

PKGNAME=Trezor-Suite
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Management software for Trezor hardware cryptocurrency wallets"
URL="https://github.com/trezor/trezor-suite/releases"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=x86_64
        ;;
    aarch64)
        arch=arm64
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

PKGURL=$(eget --list --latest $URL $(epm print constructname Trezor-Suite "$VERSION" linux-$arch AppImage "-" "-"))

install_pkgurl
