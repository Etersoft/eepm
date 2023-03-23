#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vkteams

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Networking/Instant messaging|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://teams.vk.com/|" $SPEC
subst "s|^Summary:.*|Summary: VK Teams|" $SPEC

# move package to /opt
mkdir -p $BUILDROOT$PRODUCTDIR
mv $BUILDROOT/* $BUILDROOT$PRODUCTDIR
subst "s|\"/|\"$PRODUCTDIR/|" $SPEC

add_bin_exec_command $PRODUCT
# Hack against https://bugzilla.altlinux.org/43779
# Create non writeable local .desktop file
cat <<EOF >$BUILDROOT/usr/bin/$PRODUCT
#!/bin/sh
LDT=~/.local/share/applications/vkteamsdesktop.desktop
[ ! -r "\$LDT" ] && mkdir -p ~/.local/share/applications/ && echo "[Desktop Entry]" > "\$LDT" && chmod a-w "\$LDT"
exec $PRODUCTDIR/$PRODUCT "\$@"
EOF

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=VK Teams
Comment=Official desktop application for the VK Teams messaging service
Icon=$PRODUCT.png
Exec=$PRODUCT -urlcommand %u
Categories=InstantMessaging;Social;Chat;Network;
Terminal=false
MimeType=x-scheme-handler/vkteams;x-scheme-handler/myteam-messenger;
Keywords=vkteams;
EOF

pack_file /usr/share/applications/$PRODUCT.desktop

ICONURL=https://is1-ssl.mzstatic.com/image/thumb/Purple122/v4/a8/36/64/a83664d6-9401-a8a4-c845-89e0c3ab0c89/icons-bundle.png/246x0w.png
mkdir -p $BUILDROOT/usr/share/pixmaps/
epm tool eget -O $BUILDROOT/usr/share/pixmaps/$PRODUCT.png $ICONURL
[ -s $BUILDROOT/usr/share/pixmaps/$PRODUCT.png ] && pack_file /usr/share/pixmaps/$PRODUCT.png || echo "Can't download icon for the program."
subst "s|.*$PRODUCTDIR/unittests.*||" $SPEC


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

# FIXME: check the full list
filter_from_requires libQt5 libxcb "libX.*"

epm install --skip-installed glib2 libdbus libexpat libgbm libgio libgpg-error libuuid zlib fontconfig libGL libalsa libnspr libnss
