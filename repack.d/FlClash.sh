#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt

add_bin_link_command $PRODUCT /opt/$PRODUCT/$PRODUCT

ignore_lib_requires 'libjvm.so()(64bit)'
