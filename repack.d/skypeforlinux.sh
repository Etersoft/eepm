#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=skype
PRODUCTCUR=skypeforlinux
PRODUCTDIR=/opt/skype

. $(dirname $0)/common-chromium-browser.sh

# remove key install script
remove_dir /opt/skypeforlinux

move_to_opt /usr/share/skypeforlinux

# https://bugzilla.altlinux.org/45502
remove_file /usr/bin/skypeforlinux

add_bin_link_command $PRODUCTCUR $PRODUCTDIR/$PRODUCTCUR
add_bin_link_command $PRODUCT $PRODUCTCUR

fix_chrome_sandbox

fix_desktop_file /usr/bin/skypeforlinux

add_electron_deps

