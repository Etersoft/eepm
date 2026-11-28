#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vinteo-screencast
PRODUCTDIR=/opt/VinteoScreencast

. $(dirname $0)/common.sh

add_electron_deps

add_bin_link_command
fix_desktop_file

# apparmor profile is only for Ubuntu 24+ with userns restrictions, the vendor installs it in postinstall
remove_file $PRODUCTDIR/resources/apparmor-profile
