#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=codium

. $(dirname $0)/common.sh

move_to_opt

subst '1iAutoReq:yes,nomonolib,nomono' $SPEC
subst '1iAutoProv:no' $SPEC

remove_file /usr/bin/$PRODUCT
add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT

fix_desktop_file /usr/share/codium/bin/codium

#fix_chrome_sandbox

# install all requires packages before packing (the list have got with rpmreqs package | xargs echo)
epm install --skip-installed at-spi2-atk coreutils findutils gawk glib2 libalsa libatk libat-spi2-core libcairo libdbus libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+3 libnspr libnss libpango libsecret libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libxkbfile libXrandr libXrender libXScrnSaver libXtst sed
