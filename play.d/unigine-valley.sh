#!/bin/sh

PKGNAME=unigine-valley
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Unigine Valley 2013 (Unigine Benchmark) from the official site"

. $(dirname $0)/common.sh

cd_to_temp_dir

# https://assets.unigine.com/d/Unigine_valley-4.0.run
epm tool eget --latest https://benchmark.unigine.com/valley "Unigine_Valley*.run"

epm pack --install $PKGNAME *.run
