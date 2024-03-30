#!/bin/sh

PKGNAME=unigine-heaven
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Unigine Heaven 2009 (Unigine Benchmark) from the official site"
URL="https://benchmark.unigine.com/heaven"

. $(dirname $0)/common.sh

PKGURL="$(eget --list --latest https://benchmark.unigine.com/heaven "Unigine_Heaven-$VERSION.run")"

epm pack --install $PKGNAME $PKGURL
