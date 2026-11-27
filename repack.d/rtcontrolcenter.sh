#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=rtcontrolcenter
PRODUCTDIR=/opt/aktivco/rcc

. $(dirname $0)/common.sh

# The original %post/%postun only run update-desktop-database.

# librtpkcs11ecp.so is a private copy loaded via RPATH $ORIGIN:
# the application needs C_EX_GetFunctionListExtended, missed in older system librtpkcs11ecp.

move_file $PRODUCTDIR/$PRODUCT.png /usr/share/pixmaps/$PRODUCT.png
subst "s|^TryExec=.*|TryExec=$PRODUCT|" $BUILDROOT/usr/share/applications/ru.rutoken.$PRODUCT.desktop
subst "s|^Exec=.*|Exec=$PRODUCT|" $BUILDROOT/usr/share/applications/ru.rutoken.$PRODUCT.desktop
subst "s|^Icon=.*|Icon=$PRODUCT|" $BUILDROOT/usr/share/applications/ru.rutoken.$PRODUCT.desktop

# uses system Qt5
add_unirequires libQt5Concurrent.so.5 libQt5Core.so.5 libQt5Gui.so.5 libQt5Svg.so.5 libQt5Widgets.so.5

# pcscd and CCID reader driver are needed for Rutoken
add_requires /usr/sbin/pcscd
case "$(epm print info -p)" in
    deb)
        add_requires libccid
        ;;
    *)
        # provided by pcsc-lite-ccid in ALT and Fedora, ccid in ROSA
        add_requires ccid
        ;;
esac
