#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=hansoft
PRODUCTCUR=Hansoft

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCTCUR
add_bin_link_command $PRODUCTCUR $PRODUCT

cat <<EOF |create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Actions=Newconnection;Logoutexitall;
Categories=Development;Office;
Exec=$PRODUCT -Url %u
Icon=$PRODUCT
MimeType=x-scheme-handler/hansoft;
Name=Hansoft Client
Terminal=false
Type=Application
Version=1.0

[Desktop Action Newconnection]
Exec=$PRODUCT -NoAuto
Name=New connection
X-Hansoft-TaskType=Command

[Desktop Action Logoutexitall]
Exec=$PRODUCT -ExitAll
Name=Log out & exit all
X-Hansoft-TaskType=Command
EOF

# copied from ~.local/share/icons/se.hansoft.Exe-PMClient_7B6AC2CBB8795205B8E6DC09CB75B5E6.png
i=256
install_file ipfs://QmbYM3wS2qXtWbUg9mASMPoJmgfL6smny1m3J4PfuiDtJR /usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCT.png

add_libs_requires
