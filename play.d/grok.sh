#!/bin/sh

PKGNAME=grok
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Grok Build is a terminal-based AI coding agent from xAI"
URL="https://x.ai/cli"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
platform="linux-$arch"

BASE_URL="https://x.ai/cli"

if [ "$VERSION" = "*" ] ; then
    VERSION="$(eget -O- "$BASE_URL/stable")" || fatal "Can't get latest Grok Build version"
fi

PKGURL="$BASE_URL/grok-$VERSION-$platform"

install_pack_pkgurl $VERSION
