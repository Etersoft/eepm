#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vkteams

. $(dirname $0)/common.sh

add_bin_exec_command $PRODUCT
# Hack against https://bugzilla.altlinux.org/43779
# Create non writeable local .desktop file
cat <<EOF >$BUILDROOT/usr/bin/$PRODUCT
#!/bin/sh
LDT=~/.local/share/applications/vkteamsdesktop.desktop
[ ! -r "\$LDT" ] && mkdir -p ~/.local/share/applications/ && echo "[Desktop Entry]" > "\$LDT" && chmod a-w "\$LDT"
exec $PRODUCTDIR/$PRODUCT "\$@"
EOF

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=VK Teams
Comment=Official desktop application for the VK Teams messaging service
Icon=$PRODUCT
Exec=$PRODUCT -urlcommand %u
Categories=InstantMessaging;Social;Chat;Network;
Terminal=false
MimeType=x-scheme-handler/vkteams;x-scheme-handler/myteam-messenger;
Keywords=vkteams;
EOF

ICONURL=https://is1-ssl.mzstatic.com/image/thumb/Purple122/v4/a8/36/64/a83664d6-9401-a8a4-c845-89e0c3ab0c89/icons-bundle.png/246x0w.png
install_file $ICONURL /usr/share/pixmaps/$PRODUCT.png

subst "s|.*$PRODUCTDIR/unittests.*||" $SPEC

add_libs_requires
