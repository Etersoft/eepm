#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"


. $(dirname $0)/common.sh

mkdir -p usr/

if [ "$(head -c 13 "$TAR")" = "HYTALE-UPDATE" ] ; then
    payload_size="$(od -An -tx1 -j24 -N8 "$TAR" | tr -d ' \n')"
    [ -n "$payload_size" ] || fatal "Can't get payload size from $TAR"
    tail -c "$((0x$payload_size))" "$TAR" > payload.zip || fatal
    erc -C opt/$PRODUCT unpack payload.zip || fatal
else
    erc -C opt/$PRODUCT unpack "$TAR" || fatal
fi

install_file https://aur.archlinux.org/cgit/aur.git/plain/com.hypixel.HytaleLauncher.png?h=hytale-launcher-bin /usr/share/pixmaps/$PRODUCT.png

cat <<EOF | create_file /usr/share/applications/com.hypixel.HytaleLauncher.desktop
[Desktop Entry]
Name=Hytale Launcher
Comment=Hytale Launcher
Exec=env __NV_DISABLE_EXPLICIT_SYNC=1 WEBKIT_DISABLE_DMABUF_RENDERER=1 DESKTOP_STARTUP_ID=com.hypixel.HytaleLauncher $PRODUCT
Icon=$PRODUCT
Terminal=false
Type=Application
Categories=Game;
StartupWMClass=com.hypixel.HytaleLauncher
EOF

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt/$PRODUCT usr || fatal

return_tar $PKGNAME.tar
