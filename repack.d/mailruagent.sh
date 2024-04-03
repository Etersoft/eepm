#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/agent

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Mail.ru Agent for Linux
Comment=Simple way to communicate and nothing extra. New design, group chats and much more!
Icon=$PRODUCT
Exec=$PRODUCT -urlcommand %u
Categories=InstantMessaging;Social;Chat;Network;
Terminal=false
MimeType=x-scheme-handler/icq;
Keywords=icq;
EOF

subst "s|.*/opt/icq/unittests.*||" $SPEC

add_libs_requires
