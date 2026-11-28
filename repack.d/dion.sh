#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=dion
PRODUCTDIR=/opt/Dion

. $(dirname $0)/common.sh

# the original %post only writes /etc/dion/dion-startup-policy.json
# when DIONAUTOLAUNCH/DIONPLATFORMDOMAIN are set during install (admin policy)
add_bin_link_command

fix_desktop_file

add_electron_deps
