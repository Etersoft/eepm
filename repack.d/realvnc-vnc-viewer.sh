#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst '1iConflicts: tigervnc' $SPEC

# set_autoreq 'yes'
add_libs_requires
