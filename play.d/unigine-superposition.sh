#!/bin/sh

PKGNAME=unigine-superposition
OPKGNAME=Unigine_Superposition
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Unigine Superposition 2017 (Unigine Benchmark) from the official site"

. $(dirname $0)/common.sh

convert_makeself_to_tar()
{
    offset=`head -n 402 "$1" | wc -c | tr -d " "`
    dd if="$1" ibs=$offset skip=1 obs=1024 conv=sync | gzip -cd > "$(basename "$1" .run).tar"
}

PKGDIR=$(mktemp -d)
trap "rm -fr $PKGDIR" EXIT

cd $PKGDIR || fatal
# https://assets.unigine.com/d/Unigine_superposition-4.0.run
epm tool eget --latest https://benchmark.unigine.com/superposition "$OPKGNAME*.run"

mv $OPKGNAME*.run $(echo $OPKGNAME*.run | tr "[A-Z_]" "[a-z-]")

convert_makeself_to_tar $PKGNAME*.run

epm install $PKGNAME*.tar
