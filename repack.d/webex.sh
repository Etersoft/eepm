#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=webex

. $(dirname $0)/common.sh

# drop external requires
filter_from_requires libutil.so

set_autoreq 'yes'
