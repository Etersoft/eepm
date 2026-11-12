#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

PRODUCT=ceno-wine
PRODUCTDIR=/opt/eepm-wine/$PRODUCT

. $(dirname $0)/common.sh

add_requires '/usr/bin/wine'
add_requires '/usr/bin/winepath'

add_bin_link_command $PRODUCT $PRODUCTDIR/run.sh

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=Ceno Browser (Wine)
Comment=Censorship-resistant web browser
Exec=$PRODUCT %u
Type=Application
Terminal=false
StartupNotify=true
StartupWMClass=ceno.exe
Icon=$PRODUCT
Categories=Network;WebBrowser;
MimeType=text/html;x-scheme-handler/http;x-scheme-handler/https;
EOF

install_file .$PRODUCTDIR/browser/VisualElements/VisualElements_150.png /usr/share/pixmaps/$PRODUCT.png
