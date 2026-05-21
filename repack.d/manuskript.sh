#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=manuskript

. $(dirname $0)/common.sh

for i in 16 32 64 128 256 512; do
    install_file /usr/share/manuskript/icons/Manuskript/icon-${i}px.png /usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCT.png
done

install_file /usr/share/manuskript/icons/Manuskript/$PRODUCT.svg /usr/share/icons/hicolor/scalable/apps/$PRODUCT.svg 

move_to_opt

subst "s|/usr/share/manuskript/|$PRODUCTDIR/|" usr/bin/manuskript

fix_desktop_file /usr/bin/manuskript
fix_desktop_file /usr/share/manuskript/icons/Manuskript/icon-512px.png $PRODUCT

case "$(epm print info -s)" in
    fedora)
        # Fedora does not resolve the generic PyQt5 requires here, use real package names.
        add_directrequires python3-qt5 python3-qt5-webengine qt5-qtsvg
        ;;
    *)
        add_unirequires 'python3(PyQt5)' 'libQt5Svg.so.5'
        ;;
esac
