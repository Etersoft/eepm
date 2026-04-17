#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# bundled Qt6, Wayland shell integration not bundled (optional)
ignore_lib_requires 'libQt6WlShellIntegration.so.*'

add_bin_link_command Throne /usr/bin/throne
