#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# foreign binaries in /usr/lib/apache-netbeans/ide/bin/nativeexecution
ignore_lib_requires libc.so.1 libjawt.so libpthread.1

add_libs_requires

