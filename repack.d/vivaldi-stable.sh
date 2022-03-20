#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vivaldi
PRODUCTCUR=vivaldi-stable
PRODUCTDIR=/opt/vivaldi


. $(dirname $0)/common-chromium-browser.sh

set_alt_alternatives 65

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

#install_deps

# install all requires packages before packing (the list have got with rpmreqs package | xargs echo)
epm install --skip-installed at-spi2-atk file gawk GConf glib2 grep libatk libat-spi2-core libcairo libcups libdbus libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+3 libnspr libnss libpango \
            libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender libXtst sed tar which xdg-utils xprop


subst "1i%filter_from_requires /.opt.google.chrome.WidevineCdm/d" $SPEC

echo "You also can install chrome via epm play chrome to use WidevineCdm"
