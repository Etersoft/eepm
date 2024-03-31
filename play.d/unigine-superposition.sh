#!/bin/sh

PKGNAME=unigine-superposition
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Unigine Superposition 2017 (Unigine Benchmark) from the official site"
URL="https://benchmark.unigine.com/superposition"

. $(dirname $0)/common.sh

# https://assets.unigine.com/d/Unigine_superposition-4.0.run
PKGURL=$(eget --list --latest https://benchmark.unigine.com/superposition "Unigine_Superposition-$VERSION.run")

install_pack_pkgurl
