#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# OneScript 2.x bundles .NET runtime; libcoreclrtraceptprovider.so links to
# liblttng-ust.so.0 only for optional LTTng/EventPipe tracing.
ignore_lib_requires liblttng-ust.so.0
