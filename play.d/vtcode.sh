#!/bin/sh

PKGNAME=vtcode
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="VT Code - open-source Rust terminal coding agent"
URL="https://github.com/vinhnx/VTCode"

. $(dirname $0)/common.sh

# the binary needs GLIBC_2.39
is_glibc_enough 2.39 || fatal "glibc 2.39 or above is required for $PKGNAME."

arch="$(epm print info -a)"

if [ "$VERSION" = "*" ] ; then
    # the leading slash skips compat-vtcode-*.tar.gz.compat
    PKGURL="$(get_github_url "$URL/" "/vtcode-[0-9]*-$arch-unknown-linux-gnu.tar.gz$")"
else
    PKGURL="$URL/releases/download/$VERSION/vtcode-$VERSION-$arch-unknown-linux-gnu.tar.gz"
fi

install_pack_pkgurl
