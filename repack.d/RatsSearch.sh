#!/bin/sh

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# Upstream AppImage is named RatsSearch, but play.d package name is rats-search.
subst "s|^Name:.*|Name: rats-search|" "$SPEC"

add_bin_link_command rats-search RatsSearch
