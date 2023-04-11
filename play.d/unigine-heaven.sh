#!/bin/sh

PKGNAME=unigine-heaven
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Unigine Heaven 2009 (Unigine Benchmark) from the official site"

. $(dirname $0)/common.sh

PKGURL="$(eget --list --latest https://benchmark.unigine.com/heaven "Unigine_Heaven*.run")"

epm pack --install $PKGNAME $PKGURL
