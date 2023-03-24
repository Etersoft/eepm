#!/bin/sh

PKGNAME=unigine-heaven
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Unigine Heaven 2009 (Unigine Benchmark) from the official site"

. $(dirname $0)/common.sh

PKGDIR=$(mktemp -d)
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

# https://assets.unigine.com/d/Unigine_Heaven-4.0.run
epm tool eget --latest https://benchmark.unigine.com/heaven "Unigine_Heaven*.run"

epm pack --install $PKGNAME Unigine_Heaven*.run
