#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=yandex-browser
PRODUCTCUR=yandex-browser-stable
PRODUCTDIR=/opt/yandex/browser

subst '1iConflicts:yandex-browser-beta' $SPEC

. $(dirname $0)/common-chromium-browser.sh

set_alt_alternatives 65

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

install_deps


#if ! grep -q '^"/usr/bin/yandex-browser"' $SPEC ; then
#    subst 's|\(.*/usr/bin/yandex-browser.*\)|"/usr/bin/yandex-browser"\n\1|' $SPEC
#fi
