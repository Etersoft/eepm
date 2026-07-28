#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=rstudio
PRODUCTDIR=/usr/lib/$PRODUCT

. $(dirname $0)/common.sh

add_bin_exec_command $PRODUCT

fix_desktop_file "$PRODUCTDIR/$PRODUCT" $PRODUCT

# fix bug in upstream
subst 's|/usr/lib/rstudio/bin/rstudio|$PRODUCTDIR/$PRODUCT|' $BUILDROOT$PRODUCTDIR/resources/app/bin/rstudio-backtrace.sh

ignore_lib_requires libffmpeg.so
# Some bundled prebuilds add a bare musl libc requirement; glibc is tracked via libc.so.6.
ignore_lib_requires 'libc.so()(64bit)'

add_electron_deps
