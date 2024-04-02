#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PKGNAME="yandex-messenger"
subst "s|^Name:.*|Name: $PKGNAME|" $SPEC

PRODUCTDIR=/opt/yandex-messenger
PRODUCTCUR=yandex-messenger
. $(dirname $0)/common-chromium-browser.sh

move_to_opt "/opt/Yandex Messenger"

add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCT
add_bin_link_command $PRODUCTCUR $PRODUCT

fix_desktop_file "/opt/Yandex Messenger" "/opt/yandex-messenger"

fix_chrome_sandbox

add_electron_deps
