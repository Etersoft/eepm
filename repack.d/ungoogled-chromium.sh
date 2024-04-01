#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=ungoogled-chromium

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/chrome-wrapper

use_system_xdg

install_file $PRODUCTDIR/product_logo_48.png /usr/share/pixmaps/$PRODUCT.png

#fix duplication .desktop file
subst "s|chromium-devel|ungoogled-chromium|" $BUILDROOT/opt/$PRODUCT/chrome-wrapper

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
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

set_alt_alternatives 65

[ -f .$PRODUCTDIR/chrome_sandbox ] && move_file $PRODUCTDIR/chrome_sandbox $PRODUCTDIR/chrome-sandbox
fix_chrome_sandbox

add_chromium_deps
