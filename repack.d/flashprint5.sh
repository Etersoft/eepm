#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_file /usr/lib/libOCCTWrapper.so.1 /usr/lib64/libOCCTWrapper.so.1

add_libs_requires
