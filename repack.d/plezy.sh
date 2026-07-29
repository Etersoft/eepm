#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=plezy
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

[ -f "$BUILDROOT$PRODUCTDIR/lib/crashpad_handler" ] && chmod 0755 "$BUILDROOT$PRODUCTDIR/lib/crashpad_handler"

ignore_lib_requires "libjvm.so()(64bit)"

if [ "$(epm print info -s)" = "alt" ] ; then
    add_requires "libcurl4-openssl"
    epm assure patchelf || exit
    a= patchelf --replace-needed libcurl.so.4 libcurl-openssl.so.4 \
        "$BUILDROOT$PRODUCTDIR/lib/libsentry.so"
fi

add_bin_exec_command "$PRODUCT" "$PRODUCTDIR/plezy"
