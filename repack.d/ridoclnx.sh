#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=ridoclnx

. $(dirname $0)/common.sh

move_to_opt

add_bin_exec_command
subst "2icd $PRODUCTDIR" usr/bin/$PRODUCT

fix_desktop_file /usr/share/ridoclnx/ridoclnx.ico
fix_desktop_file /usr/share/ridoclnx/ridoclnx
fix_desktop_file /usr/share/ridoclnx/ $PRODUCTDIR

add_libs_requires
