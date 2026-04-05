#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=ayugram-desktop

. $(dirname $0)/common.sh

# replace old package name
add_conflicts ayugram
add_obsoletes ayugram

# /usr/bin/AyuGram already in package, add lowercase alias
add_bin_link_command ayugram AyuGram

