#!/bin/sh

PKGNAME=unigine-heaven
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Unigine Heaven 2009 (Unigine Benchmark) from the official site"
URL="https://benchmark.unigine.com/heaven"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # Download links are stored in the site's JavaScript module, not in HTML.
    JSURL="$(eget --list --latest "$URL" 'components-*.js')"
    PKGURL="$(fetch_url "$JSURL" | grep -aoE 'https://assets\.unigine\.com/d/Unigine_Heaven-[0-9.]+\.run' | head -n1)"
else
    PKGURL="https://assets.unigine.com/d/Unigine_Heaven-$VERSION.run"
fi

install_pack_pkgurl
