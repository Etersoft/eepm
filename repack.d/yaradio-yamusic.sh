#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=yaradio-yamusic
PRODUCTDIR=/opt/YaMusic.app

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command

add_electron_deps

fix_chrome_sandbox

fix_desktop_file

if [ -f usr/share/icons/hicolor/0x0/apps/yaradio-yamusic.png ] ; then
    install_file usr/share/icons/hicolor/0x0/apps/yaradio-yamusic.png /usr/share/icons/hicolor/256x256/apps/yaradio-yamusic.png
    remove_dir /usr/share/icons/hicolor/0x0/
fi
