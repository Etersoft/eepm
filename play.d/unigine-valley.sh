#!/bin/sh

PKGNAME=unigine-valley
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Unigine Valley 2013 (Unigine Benchmark) from the official site"

. $(dirname $0)/common.sh

# https://assets.unigine.com/d/Unigine_valley-4.0.run
PKGURL=$(eget --latest https://benchmark.unigine.com/valley "Unigine_Valley*.run")

epm pack --install $PKGNAME $PKGURL
