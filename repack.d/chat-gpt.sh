#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

is_soname_present libssl.so.3 || fatal "This package needs OpenSSL 3."

add_libs_requires
