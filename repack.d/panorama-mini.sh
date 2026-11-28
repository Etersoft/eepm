#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=panorama-mini
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

move_to_opt /usr/PanoramaMini15

# the app uses the system Qt5
add_unirequires libQt5Core.so.5 libQt5Gui.so.5 libQt5Widgets.so.5 libQt5Sql.so.5 libQt5PrintSupport.so.5 \
                libQt5Svg.so.5 libQt5OpenGL.so.5 libQt5Pas.so.1

# replace upstream bash launcher
remove_file $PRODUCTDIR/startgis.bat
cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
# directory for Guardant key temp files
GRD_IPC_NAME="\$HOME/guardant_files/"
mkdir -p "\$GRD_IPC_NAME"
export GRD_IPC_NAME
export USB_DEVFS_PATH=/dev/bus/usb
export LC_ALL=""
export LC_NUMERIC="C"
export LD_LIBRARY_PATH="$PRODUCTDIR\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
export QT_SUPPORT_GL_CHILD_WIDGETS="1"
export QT_X11_NO_MITSHM="1"
cd $PRODUCTDIR || exit
exec $PRODUCTDIR/panorama-mini.exe "\$@"
EOF

# desktop file and icon (the postinstall script copies the desktop file to user desktops)
install_file $PRODUCTDIR/shortcut/gispanorama-mini.desktop /usr/share/applications/$PRODUCT.desktop
subst "s|^Exec=.*|Exec=$PRODUCT %F|" $BUILDROOT/usr/share/applications/$PRODUCT.desktop
subst "s|^Icon=.*|Icon=$PRODUCT|" $BUILDROOT/usr/share/applications/$PRODUCT.desktop
subst "/^Encoding=/d" $BUILDROOT/usr/share/applications/$PRODUCT.desktop
install_file $PRODUCTDIR/panorama-mini.png /usr/share/pixmaps/$PRODUCT.png

# Guardant USB key access (from the postinstall script), without Astra Linux specific MACLABEL/PDPL lines
grep -v -E 'MACLABEL|PDPL' $BUILDROOT$PRODUCTDIR/shortcut/95-grdnt.rules | create_file /usr/lib/udev/rules.d/95-$PRODUCT-grdnt.rules

remove_dir $PRODUCTDIR/shortcut

# fonts (from the postinstall script)
for i in "$BUILDROOT$PRODUCTDIR"/ttf_panorama/* ; do
    i="$(basename "$i")"
    install_file "$PRODUCTDIR/ttf_panorama/$i" "/usr/share/fonts/ttf/$PRODUCT/$i"
done

# shared data directory is writable for all users (as in the vendor's postinstall script)
pack_dir /var/Panorama
find "$BUILDROOT/var/Panorama/PanoramaMini15" -type f -exec chmod 0666 {} +
for i in $(cd "$BUILDROOT" && find var/Panorama -type d) ; do
    subst "s|^%dir \"/$i/*\"$|%attr(0777,root,root) %dir \"/$i\"|" $SPEC
    subst "s|^%dir /$i/*$|%attr(0777,root,root) %dir /$i|" $SPEC
done
