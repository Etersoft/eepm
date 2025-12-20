#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=rstudio
PRODUCTDIR=/usr/lib/$PRODUCT

. $(dirname $0)/common.sh

add_bin_exec_command $PRODUCT

# fix bug in upstream
subst 's|/usr/lib/rstudio/bin/rstudio|$PRODUCTDIR/$PRODUCT|' $BUILDROOT$PRODUCTDIR/resources/app/bin/rstudio-backtrace.sh

ignore_lib_requires libffmpeg.so

add_electron_deps

