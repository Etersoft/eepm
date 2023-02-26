#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# TODO: write developers about broken package name
PKGNAME="synology-chat"
subst "s|^Name:.*|Name: $PKGNAME|" $SPEC

PRODUCT=synochat
PRODUCTCUR=synology-chat
PRODUCTDIR="/opt/Synology/SynologyChat"

. $(dirname $0)/common-chromium-browser.sh

# many side effects due the space
move_to_opt "/opt/Synology Chat"
subst "s|/opt/Synology Chat/||" $BUILDROOT/usr/share/applications/$PRODUCT.desktop

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

install_deps

fix_chrome_sandbox

