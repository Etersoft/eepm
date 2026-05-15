#!/bin/sh

PKGNAME=FlClashX
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Fork of FlClash | A multi-platform proxy client based on ClashMeta, simple and easy to use"
URL="https://github.com/pluralplay/FlClashX"

. $(dirname $0)/common.sh

arch=$(epm print info --debian-arch)

PKGURL=$(get_github_url https://github.com/pluralplay/FlClashX "FlClashX-linux-$arch.deb")

install_pkgurl
