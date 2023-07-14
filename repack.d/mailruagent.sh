#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PREINSTALL_PACKAGES="glib2 libdbus libexpat libgbm libgio libgpg-error libuuid zlib fontconfig libGL"

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Networking/Instant messaging|" $SPEC
subst "s|^License: unknown$|Proprietary|" $SPEC
subst "s|^URL:.*|URL: https://https://agent.mail.ru/linux|" $SPEC
subst "s|^Summary:.*|Summary: Mail.ru Agent for Linux|" $SPEC

add_bin_exec_command $PRODUCT

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
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

pack_file /usr/share/applications/$PRODUCT.desktop

# https://hb.bizmrg.com/icq-www/linux/x64/packages/10.0.13286/icq.png
install_file https://dashboard.snapcraft.io/site_media/appmedia/2020/04/icq_copy.png /usr/share/pixmaps/$PRODUCT.png

subst "s|.*/opt/icq/unittests.*||" $SPEC

# ignore embedded libs
filter_from_requires libQt5 libxcb "libX.*"

if epm assure patchelf ; then
cd $BUILDROOT$PRODUCTDIR
for i in $PRODUCT  ; do
    a= patchelf --set-rpath '$ORIGIN/lib' $i
done

for i in lib/*.so.*  ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done

for i in QtQuick.2/lib*.so  ; do
    a= patchelf --set-rpath '$ORIGIN/../lib' $i
done

for i in QtQuick/*/lib*.so  ; do
    a= patchelf --set-rpath '$ORIGIN/../../lib' $i
done
fi

set_autoreq 'yes'
