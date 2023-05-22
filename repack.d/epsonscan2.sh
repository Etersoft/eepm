#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst '1iAutoProv:no' $SPEC

if epm assure patchelf ; then
for i in usr/lib64/epsonscan2/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN/' $i || continue
done
fi
