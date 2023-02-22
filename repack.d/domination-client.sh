#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=domination-client
PRODUCTDIR="/opt/Domination/Client"

. $(dirname $0)/common-chromium-browser.sh

# many side effects due the space
move_to_opt "/opt/Domination Client"
subst "s|/opt/Domination Client/||" $BUILDROOT/usr/share/applications/domination-client.desktop

add_bin_link_command

install_deps

fix_chrome_sandbox

