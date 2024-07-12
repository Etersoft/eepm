#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

add_requires 'python3(sqlite3)' 'python3(requests)' 'python3(PyQt5)' '/usr/bin/aria2c'

add_libs_requires
