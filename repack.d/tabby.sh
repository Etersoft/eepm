#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_link_command tabby-ml $PRODUCTDIR/tabby
#add_bin_link_command llama-server $PRODUCTDIR/llama-server
