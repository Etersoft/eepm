#!/bin/sh

load_helper()
{
    . ../bin/$1
}

PMTYPE=apt-rpm

load_helper epm-repack

td=$(mktemp -d) || fatal
mkdir -p $td/{/etc,/opt/test}

cp -f test.spec.in test.spec
__fix_spec test "$td" test.spec

rm -rfv $td
