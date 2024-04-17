#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_libs_requires

add_bin_link_command rad
add_bin_link_command git-remote-rad
add_bin_link_command rad-web
add_bin_link_command radicle-httpd
add_bin_link_command radicle-node
