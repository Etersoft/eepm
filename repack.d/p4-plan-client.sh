#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=p4-plan-client
PRODUCTCUR=HelixPlan
PRODUCTDIR=/opt/HelixPlan

. $(dirname $0)/common.sh

subst "s|^Name:.*|Name: p4-plan-client|" "$SPEC"

add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCTCUR

cat <<EOF |create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Actions=Newconnection;Logoutexitall;
Categories=Development;Office;
Exec=$PRODUCT -Url %u
Icon=$PRODUCT
MimeType=x-scheme-handler/hansoft;
Name=P4 Plan Client
Comment=P4 Plan client
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

# Upstream .deb does not ship a standalone icon file, so use the current
# official product favicon published in Perforce docs.
i=512
install_file https://help.perforce.com/hansoft/current/Skins/Favicons/favicon-p4-plan.png /usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCT.png
