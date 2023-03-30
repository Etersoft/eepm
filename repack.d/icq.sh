#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=icq
PRODUCTCUR=icq

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Networking/Instant messaging|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://icq.com/desktop/ru|" $SPEC
subst "s|^Summary:.*|Summary: ICQ New for Linux|" $SPEC

# move package to /opt
mkdir -p $BUILDROOT$PRODUCTDIR
mv $BUILDROOT/* $BUILDROOT$PRODUCTDIR
subst "s|\"/|\"$PRODUCTDIR/|" $SPEC

add_bin_exec_command $PRODUCT
# Hack against https://bugzilla.altlinux.org/43779
# Create non writeable local .desktop file
cat <<EOF >$BUILDROOT/usr/bin/$PRODUCT
#!/bin/sh
LDT=~/.local/share/applications/icqdesktop.desktop
[ ! -r "\$LDT" ] && mkdir -p ~/.local/share/applications/ && echo "[Desktop Entry]" > "\$LDT" && chmod a-w "\$LDT"
exec $PRODUCTDIR/$PRODUCT "\$@"
EOF


# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=ICQ for Linux
Comment=Simple way to communicate and nothing extra. New design, group chats and much more!
Icon=icq
Exec=icq -urlcommand %u
Categories=InstantMessaging;Social;Chat;Network;
Terminal=false
MimeType=x-scheme-handler/icq;
Keywords=icq;
EOF

pack_file /usr/share/applications/$PRODUCT.desktop

install_file https://dashboard.snapcraft.io/site_media/appmedia/2020/04/icq_copy.png /usr/share/pixmaps/$PRODUCT.png

subst "s|.*/opt/icq/unittests.*||" $SPEC

# ignore embedded libs
filter_from_requires libQt5 libxcb "libX.*"

epm assure patchelf || exit
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


epm install --skip-installed glib2 libdbus libexpat libgbm libgio libgpg-error libuuid zlib fontconfig libGL
