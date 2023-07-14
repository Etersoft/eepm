#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=lycheeslicer
PRODUCTDIR=/opt/LycheeSlicer

PREINSTALL_PACKAGES="at-spi2-atk coreutils glib2 libalsa libatk libat-spi2-core libcairo libcups libdbus libdrm libexpat libgbm libgio libGL libgtk+3 libnspr libnss libpango libX11 libxcb libXcomposite libXdamage libXext libXfixes libxkbcommon libXrandr zlib"

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command
#add_bin_link_command $PRODUCTCUR $PRODUCT

install_deps

fix_chrome_sandbox

fix_desktop_file

# ignore embedded libs
filter_from_requires libQt5 node seamonkey thunderbird

set_autoreq 'yes'

