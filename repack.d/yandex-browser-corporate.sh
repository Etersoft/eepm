#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=yandex-browser
PRODUCTCUR=yandex-browser-corporate
PRODUCTDIR=/opt/yandex/browser

. $(dirname $0)/common-chromium-browser.sh

add_conflicts yandex-browser-stable yandex-browser-beta
add_provides "yandex-browser = %version"

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

chmod a-x .$PRODUCTDIR/update-ffmpeg
