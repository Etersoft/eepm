#!/bin/sh

PKGNAME=unigine-superposition
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Unigine Superposition 2017 (Unigine Benchmark) from the official site"

. $(dirname $0)/common.sh

cd_to_temp_dir

# https://assets.unigine.com/d/Unigine_superposition-4.0.run
epm tool eget --latest https://benchmark.unigine.com/superposition "Unigine_Superposition*.run"

epm pack --install $PKGNAME *.run
