#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=ungoogled-chromium

. $(dirname $0)/common-chromium-browser.sh

#subst '1iAutoProv:no' $SPEC

# move package to /opt
ROOTDIR=$(basename $(find $BUILDROOT -mindepth 1 -maxdepth 1 -type d))
subst "s|^License: unknown$|License: BSD-3-Clause license|" $SPEC
subst "s|^Summary:.*|Summary: Google Chromium, sans integration with Google|" $SPEC

move_to_opt /$ROOTDIR

add_bin_link_command $PRODUCT $PRODUCTDIR/chrome-wrapper

use_system_xdg

install_file $PRODUCTDIR/product_logo_48.png /usr/share/pixmaps/$PRODUCT.png

 create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Ungoogled Chromium Web Browser
Name[ru]=Веб-браузер Ungoogled Chromium
Comment=Google Chromium, sans integration with Google
Icon=$PRODUCT
Exec=$PRODUCT %u
Categories=GTK;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
Terminal=false
GenericName=Ungoogle Chromium Web Browser
GenericName[ru]=Веб-браузер Ungoogled Chromium
EOF

pack_file /usr/share/applications/$PRODUCT.desktop

set_alt_alternatives 65

fix_chrome_sandbox $PRODUCTDIR/chrome_sandbox

install_deps
