#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=yandex-browser
PRODUCTCUR=yandex-browser-beta
PRODUCTDIR=/opt/yandex/browser-beta

. $(dirname $0)/common-chromium-browser.sh

subst '1iConflicts: yandex-browser-stable' $SPEC
subst '10iProvides: yandex-browser = %{version}' $SPEC

add_findreq_skiplist $PRODUCTDIR/update-ffmpeg

# this package can be missed
epm install --skip-installed --no-remove fonts-ttf-google-noto-emoji-color && add_requires fonts-ttf-google-noto-emoji-color

set_alt_alternatives 65

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

add_chromium_deps

fix_desktop_file /usr/bin/$PRODUCTCUR
