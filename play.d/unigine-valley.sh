#!/bin/sh

PKGNAME=unigine-valley
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Unigine Valley 2013 (Unigine Benchmark) from the official site"
URL="https://benchmark.unigine.com/valley"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # Download links are stored in the site's JavaScript module, not in HTML.
    JSURL="$(eget --list --latest "$URL" 'components-*.js')"
    PKGURL="$(fetch_url "$JSURL" | grep -aoE 'https://assets\.unigine\.com/d/Unigine_Valley-[0-9.]+\.run' | head -n1)"
else
    PKGURL="https://assets.unigine.com/d/Unigine_Valley-$VERSION.run"
fi

install_pack_pkgurl
