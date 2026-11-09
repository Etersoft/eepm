#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=grok-bot
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# upstream installs into the path with a space
move_to_opt "/opt/Grok Bot"

# AppArmor profile is installed by upstream postinst only (we drop it)
remove_file $PRODUCTDIR/resources/apparmor-profile

add_bin_link_command

add_electron_deps
add_libs_requires
