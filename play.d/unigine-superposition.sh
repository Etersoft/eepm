#!/bin/sh

PKGNAME=unigine-superposition
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Unigine Superposition 2017 (Unigine Benchmark) from the official site"
URL="https://benchmark.unigine.com/superposition"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # Download links are stored in the site's JavaScript module, not in HTML.
    JSURL="$(eget --list --latest "$URL" 'components-*.js')"
    PKGURL="$(fetch_url "$JSURL" | grep -aoE 'https://assets\.unigine\.com/d/Unigine_Superposition-[0-9.]+\.run' | head -n1)"
else
    PKGURL="https://assets.unigine.com/d/Unigine_Superposition-$VERSION.run"
fi

install_pack_pkgurl
