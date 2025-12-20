#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PREINSTALL_PACKAGES="libbz2.so.1()(64bit)"

. $(dirname $0)/common.sh

move_to_opt "/usr/lib64/beyondcompare"

subst "s|/usr/lib64/beyondcompare|$PRODUCTDIR|" usr/bin/$PRODUCT

if ! is_soname_present libbz2.so.1.0 ; then
    # fIXME: https://bugzilla.altlinux.org/35320
    ignore_lib_requires 'libbz2.so.1.0'
    is_soname_present libbz2.so.1 || fatal "Can't find libbz2.so.1"
    ln -s -v $(get_path_by_soname "libbz2.so.1") .$PRODUCTDIR/libbz2.so.1.0
    pack_file $PRODUCTDIR/libbz2.so.1.0
    add_unirequires libbz2.so.1
fi

# as in original package
add_unirequires /usr/bin/pdftotext

