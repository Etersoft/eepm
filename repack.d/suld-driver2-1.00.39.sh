#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_requires suld-driver2-common-1 suld-ppd-4
add_unirequires cups libsane.so.1

# Xerox ships a different libsane-smfp backend and smfp.conf at the same paths.
add_conflicts xerox-spl-driver

if [ "$(epm print info -p)" != "deb" ] ; then
    # generic.sh moves Debian's multiarch links; keep the backend in the native SANE directory.
    remove_dir /usr/lib64/sane
    move_dir /usr/lib/sane /usr/lib64/sane
fi
