#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# add conflicts to all alternatives
for i in kubo kubo-beta ; do
    [ "$i" = "$PRODUCT" ] && continue
    subst "1iConflicts: $i" $SPEC
done


subst "s|^Group:.*|Group: File tools|" $SPEC
subst "s|^License:.*$|License: MIT/Apache-2.0|" $SPEC
subst "s|^URL:.*|URL: https://github.com/ipfs/kubo|" $SPEC
subst "s|^Summary:.*|Summary: An IPFS implementation in Go|" $SPEC

set_autoreq 'yes'

subst '1iConflicts: go-ipfs' $SPEC
subst '1iProvides: go-ipfs' $SPEC

