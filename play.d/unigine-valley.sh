#!/bin/sh

PKGNAME=unigine-valley
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Unigine Valley 2013 (Unigine Benchmark) from the official site"
URL="https://benchmark.unigine.com/valley"

. $(dirname $0)/common.sh

# https://assets.unigine.com/d/Unigine_valley-4.0.run
PKGURL=$(eget --list --latest https://benchmark.unigine.com/valley "Unigine_Valley-$VERSION.run") || fatal "Can't get package URL"

install_pack_pkgurl
