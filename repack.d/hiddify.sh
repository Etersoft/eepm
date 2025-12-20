#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

#remove garbage from version in spec
sed -i -e 's/^\(Version: [^+]*\)+.*/\1/' $SPEC

move_to_opt
add_bin_link_command

