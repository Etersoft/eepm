#!/bin/sh

PKGNAME=unigine-valley
OPKGNAME=Unigine_Valley
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Unigine Valley 2013 (Unigine Benchmark) from the official site"

. $(dirname $0)/common.sh

convert_makeself_to_tar()
{
    offset=`head -n 403 "$1" | wc -c | tr -d " "`
    dd if="$1" ibs=$offset skip=1 obs=1024 conv=sync | gzip -cd > "$(basename "$1" .run).tar"
}

PKGDIR=$(mktemp -d)
trap "rm -fr $PKGDIR" EXIT

cd $PKGDIR || fatal
# https://assets.unigine.com/d/Unigine_valley-4.0.run
eget --latest https://benchmark.unigine.com/valley "$OPKGNAME*.run"

mv $OPKGNAME*.run $(echo $OPKGNAME*.run | tr "[A-Z_]" "[a-z-]")

convert_makeself_to_tar $PKGNAME*.run

epm install $PKGNAME*.tar
