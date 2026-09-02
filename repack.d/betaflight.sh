#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"
PRODUCT=betaflight

. $(dirname $0)/common.sh

add_conflicts betaflight-configurator

# The upstream package installs its launcher directly to /usr/bin.
add_bin_link_command "$PRODUCT" /usr/bin/betaflight-app
