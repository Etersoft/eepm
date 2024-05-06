#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

remove_file /opt/far2l-portable/usr/lib/x86_64-linux-gnu/libsamba-policy.cpython-310-x86-64-linux-gnu.so.0
remove_file /opt/far2l-portable/usr/lib/x86_64-linux-gnu/samba/libsamba-python.cpython-310-x86-64-linux-gnu.so.0
remove_file /opt/far2l-portable/usr/lib/x86_64-linux-gnu/samba/libsamba-net.cpython-310-x86-64-linux-gnu.so.0
remove_file /opt/far2l-portable/usr/lib/x86_64-linux-gnu/libsamba-policy.cpython-310-x86-64-linux-gnu.so.0.0.1

add_conflicts far2l
fix_desktop_file usr/bin/far2l $PRODUCT

add_libs_requires
