#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# https://bugzilla.altlinux.org/show_bug.cgi?id=39099
filter_from_requires '\\/opt\\/Dialog'

set_autoreq 'yes'
