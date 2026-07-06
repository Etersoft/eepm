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

# Yandex ships two near-identical launchers: yandex-browser.desktop (visible)
# and ru.yandex.desktop.browser.desktop (keeps the XDG portal app id stable,
# meant to be hidden via NoDisplay=true). Upstream places NoDisplay=true after
# the [Desktop Action] sections, so it lands in an action group, not in
# [Desktop Entry], and both files show up in the menu as "Yandex Browser".
# Hide the reverse-DNS copy, but only while the visible launcher still exists.
if [ -r $BUILDROOT/usr/share/applications/ru.yandex.desktop.browser.desktop ] && [ -r $BUILDROOT/usr/share/applications/yandex-browser.desktop ] ; then
    subst '/^\[Desktop Entry\]$/a NoDisplay=true' $BUILDROOT/usr/share/applications/ru.yandex.desktop.browser.desktop
fi

chmod a-x .$PRODUCTDIR/update-ffmpeg
chmod a-x .$PRODUCTDIR/update_codecs
