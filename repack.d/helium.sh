#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=helium

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCT-wrapper

use_system_xdg

fix_chrome_crashpad "$PRODUCTDIR/${PRODUCT}_crashpad_handler"

install_file $PRODUCTDIR/product_logo_256.png /usr/share/pixmaps/$PRODUCT.png

install_file $PRODUCTDIR/$PRODUCT.desktop /usr/share/applications/$PRODUCT.desktop

install_file $PRODUCTDIR/apparmor.cfg /etc/apparmor.d/helium-bin

set_alt_alternatives 65

add_chromium_deps
