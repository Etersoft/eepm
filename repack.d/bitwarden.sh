#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=bitwarden
PRODUCTDIR=/opt/Bitwarden

# install all requires packages before packing (the list have got with rpmreqs package | xargs echo)
PREINSTALL_PACKAGES="at-spi2-atk coreutils findutils gawk glib2 libalsa libatk libat-spi2-core libcairo libdbus libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+3 libnspr libnss libpango libsecret libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libxkbfile libXrandr libXrender libXScrnSaver libXtst sed"

. $(dirname $0)/common.sh

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

fix_chrome_sandbox

fix_desktop_file

