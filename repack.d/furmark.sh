#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=furmark
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_bin_exec_command 
add_bin_exec_command FurMark_GUI $PRODUCTDIR/FurMark_GUI 

add_libs_requires
