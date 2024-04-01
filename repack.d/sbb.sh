#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# see https://bugzilla.altlinux.org/47890
# hack due broken provides in libcurl-gnutls-compat
ignore_lib_requires "libcurl-gnutls.so.4"
add_requires "libcurl-gnutls.so.4(64bit)"

add_libs_requires
