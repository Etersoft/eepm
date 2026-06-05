#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# bin/elegoo-slicer is linked against libbz2.so.1.0 (Debian soname).
# ALT ships libbz2.so.1 only, so the package can't be installed as is.
# Provide a compat symlink in the app's lib dir (AppRun adds $PRODUCTDIR/bin
# to LD_LIBRARY_PATH) and depend on the real soname instead.
if ! is_soname_present libbz2.so.1.0 ; then
    ignore_lib_requires 'libbz2.so.1.0'
    is_soname_present libbz2.so.1 || fatal "Can't find libbz2.so.1"
    ln -s -v $(get_path_by_soname "libbz2.so.1") .$PRODUCTDIR/bin/libbz2.so.1.0
    pack_file $PRODUCTDIR/bin/libbz2.so.1.0
    add_unirequires libbz2.so.1
fi
