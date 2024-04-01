#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=icaclient

# Fix macro in file list
subst 's|%_h32bit|%%_h32bit|g' $SPEC

ignore_lib_requires libunwind.so.1 libgssapi.so.3
ignore_lib_requires libgstreamer-0.10.so.0 libgstapp-0.10.so.0 libgstbase-0.10.so.0 libgstinterfaces-0.10.so.0 libgstpbutils-0.10.so.0
ignore_lib_requires libgstpbutils-1.0.so.0 libgstreamer-1.0.so.0 libgstvideo-1.0.so.0 libgssapi_krb5.so.2 libgstapp-1.0.so.0 libgstbase-1.0.so.0
ignore_lib_requires libc++.so.1 libc++abi.so.1

add_libs_requires
