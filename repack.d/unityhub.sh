#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# install all requires packages before packing (the list have got with rpmreqs package | xargs echo)
PREINSTALL_PACKAGES="at-spi2-atk coreutils findutils gawk glib2 libalsa libatk libat-spi2-core libcairo libdbus libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+3 libnspr libnss libpango libsecret libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libxkbfile libXrandr libXrender libXScrnSaver libXtst sed"

. $(dirname $0)/common.sh

add_bin_link_command

fix_desktop_file

fix_chrome_sandbox

subst '1iAutoProv:no' $SPEC
subst '1iAutoReq:yes,nomono,nomonolib' $SPEC

