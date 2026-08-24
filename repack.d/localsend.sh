#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=localsend
PRODUCTCUR=localsend_app

. $(dirname $0)/common.sh

# clean version
subst "s|^\(Version: .*\)+.*|\1|" $SPEC

move_to_opt /usr/share/localsend_app

# libdartjni.so links to libjvm.so, but LocalSend starts without a system JRE.
ignore_lib_requires "libjvm.so()(64bit)" "libjli.so()(64bit)" "libjava.so()(64bit)"

add_bin_link_command $PRODUCTCUR
add_bin_link_command $PRODUCT $PRODUCTCUR
