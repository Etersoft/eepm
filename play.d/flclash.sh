#!/bin/sh

PKGNAME=FlClash
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="A multi-platform proxy client based on ClashMeta, simple and easy to use"
URL="https://github.com/chen08209/FlClash"

. $(dirname $0)/common.sh

arch=$(epm print info --debian-arch)

PKGURL=$(get_github_url https://github.com/chen08209/FlClash "FlClash-$VERSION-linux-$arch.deb")

install_pkgurl
