#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# add conflicts to all alternatives
for i in kubo kubo-beta ; do
    [ "$i" = "$PRODUCT" ] && continue
    add_conflicts $i
done

add_conflicts go-ipfs
add_provides go-ipfs

add_libs_requires

