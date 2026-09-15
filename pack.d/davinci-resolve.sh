#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
PRODUCT=davinci-resolve
PRODUCTDIR=opt/davinci-resolve

. $(dirname $0)/common.sh
# DaVinci_Resolve_Studio_20.0.1_Linux.run
# DaVinci_Resolve_18.6.5_Linux.run
BASENAME="$(basename "$TAR" .run)"

case "$BASENAME" in
    DaVinci_Resolve_Studio_*_Linux)
        PRODUCT=davinci-resolve-Studio
        VERSION="${BASENAME#DaVinci_Resolve_Studio_}"
        VERSION="${VERSION%_Linux}"
        ;;
    DaVinci_Resolve_*_Linux)
        VERSION="${BASENAME#DaVinci_Resolve_}"
        VERSION="${VERSION%_Linux}"
        ;;
    *)
        fatal "Can't extract DaVinci Resolve edition and version from $BASENAME"
        ;;
esac

epm assure unsquashfs squashfs-tools || fatal
mkdir -p "$PRODUCTDIR" || fatal

OFFSET="$("$TAR" --appimage-offset)" || fatal "Can't get AppImage offset from $TAR"
[ -n "$OFFSET" ] || fatal "Can't get AppImage offset from $TAR"
unsquashfs -no-progress -o "$OFFSET" "$TAR" || fatal "Can't unpack $TAR"
mv -v squashfs-root/* "$PRODUCTDIR/" || fatal

install -Dm0644 "$PRODUCTDIR/share/default-config.dat" -t "$PRODUCTDIR/configs"
install -Dm0644 "$PRODUCTDIR/share/log-conf.xml" -t "$PRODUCTDIR/configs"
install -Dm0644 "$PRODUCTDIR/share/default_cm_config.bin" -t "$PRODUCTDIR/DolbyVision"

install -Dm0644 "$PRODUCTDIR"/share/*.desktop -t usr/share/applications
install -Dm0644 "$PRODUCTDIR/share/DaVinciResolve.directory" -t usr/share/desktop-directories
install -Dm0644 "$PRODUCTDIR/share/DaVinciResolve.menu" -t etc/xdg/menus/applications-merged

# MIME XML files
install -Dm0644 "$PRODUCTDIR/share/resolve.xml" -t usr/share/mime/packages
install -Dm0644 "$PRODUCTDIR/share/blackmagicraw.xml" -t usr/share/mime/packages

# Udev rules
install -Dm0644 "$PRODUCTDIR/share/etc/udev/rules.d/99-BlackmagicDevices.rules" -t usr/lib/udev/rules.d
install -Dm0644 "$PRODUCTDIR/share/etc/udev/rules.d/99-ResolveKeyboardHID.rules" -t usr/lib/udev/rules.d
# install -Dm0644 opt/davinci-resolve/share/etc/udev/rules.d/99-DavinciPanel.rules -t usr/lib/udev/rules.d

echo "StartupWMClass=resolve" >> usr/share/applications/DaVinciResolve.desktop

subst "s|RESOLVE_INSTALL_LOCATION|/opt/davinci-resolve|" usr/share/applications/*.desktop 
subst "s|RESOLVE_INSTALL_LOCATION|/opt/davinci-resolve|" usr/share/desktop-directories/*
# fix for libpango.so error too

rm -v opt/davinci-resolve/libs/libglib-2.0.so*
rm -v opt/davinci-resolve/libs/libgio-2.0.so*
rm -v opt/davinci-resolve/libs/libgmodule-2.0.so*
# ln -s /usr/lib/libglib-2.0.so.0 opt/davinci-resolve/libs/libglib-2.0.so.0
rm -v opt/davinci-resolve/bin/sqlite3
rm -v opt/davinci-resolve/Onboarding/qml/Qt/labs/lottieqt/liblottieqtplugin.so

# The standalone installer places the panel framework in /usr/lib64.  Keep its
# missing libraries private to Resolve instead of installing bundled libc++ and
# Avahi libraries globally.
mkdir -p panel-framework || fatal
(
    cd panel-framework || exit
    erc --here unpack "../$PRODUCTDIR/share/panels/dvpanel-framework-linux-x86_64.tgz"
) || fatal
cp -a panel-framework/. "$PRODUCTDIR/libs/" || fatal
chmod 0755 "$PRODUCTDIR/libs/lib" || fatal

PKGNAME="$PRODUCT-$VERSION"

erc pack "$PKGNAME.tar" opt usr etc || fatal

return_tar "$PKGNAME.tar"
