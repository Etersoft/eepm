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
Icon=icq.png
Exec=icq -urlcommand %u
Categories=InstantMessaging;Social;Chat;Network;
Terminal=false
MimeType=x-scheme-handler/icq;
Keywords=icq;
EOF

pack_file /usr/share/applications/$PRODUCT.desktop

mkdir -p $BUILDROOT/usr/share/pixmaps/
epm tool eget -O $BUILDROOT/usr/share/pixmaps/$PRODUCT.png https://dashboard.snapcraft.io/site_media/appmedia/2020/04/icq_copy.png
[ -s $BUILDROOT/usr/share/pixmaps/$PRODUCT.png ] && pack_file /usr/share/pixmaps/$PRODUCT.png || echo "Can't download icon for the program."
subst "s|.*/opt/icq/unittests.*||" $SPEC
