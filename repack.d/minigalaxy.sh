#!/bin/sh

BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-python.sh

fix_python_path

add_python_requires
