#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

LIBPATH="$(cd $BUILDROOT ; echo opt/gcc-*/lib64)"

# find provides there
subst "1i%set_findprov_lib_path /$LIBPATH" $SPEC
