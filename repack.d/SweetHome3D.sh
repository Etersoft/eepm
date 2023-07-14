#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=SweetHome3D
PRODUCTCUR=sweethome3d
PRODUCTDIR=/opt/$PRODUCT

PREINSTALL_PACKAGES="coreutils glib2 libalsa libatk libcairo libcairo-gobject fontconfig libfreetype libgdk-pixbuf libgio libGL libgtk+2 libgtk+3 libnsl1 libpango libX11 libXext libXi libXrender libXtst"

. $(dirname $0)/common.sh


subst '1iConflicts:sweethome3d' $SPEC

subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://www.sweethome3d.com|" $SPEC
subst "s|^Summary:.*|Summary: An interior design application to draw house plans & arrange furniture|" $SPEC

ROOTDIR=$(basename $(find $BUILDROOT -mindepth 1 -maxdepth 1 -type d))
move_to_opt /$ROOTDIR

add_bin_exec_command
add_bin_link_command $PRODUCTCUR $PRODUCT

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=Sweet Home 3D
Name[fr]=Sweet Home 3D
Name[pt]=Sweet Home 3D
Name[ru]=Милый дом 3D
GenericName=Sweet Home 3D
GenericName[fr]=Sweet Home 3D
GenericName[ru]=Проектирование домашнего интерьера в 3D
Comment=Design Application
Comment[fr]=Application de conception d'intérieur en 3D
Comment[pt]=Aplicativo de design de interiores
Comment[ru]=Программа проектирования домашнего интерьера в 3D
Exec=$PRODUCT
Icon=$PRODUCT
Terminal=false
Type=Application
StartupNotify=true
StartupWMClass=com-eteks-sweethome3d-SweetHome3D
Categories=Graphics;2DGraphics;3DGraphics;
MimeType=application/vnd.sh3d;
EOF
pack_file /usr/share/applications/$PRODUCT.desktop

install_file $PRODUCTDIR/SweetHome3DIcon.png /usr/share/pixmaps/$PRODUCT.png

cd $BUILDROOT$PRODUCTDIR/ || fatal
if epm assure patchelf ; then
for i in runtime/lib/amd64/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN:$ORIGIN/server:$ORIGIN/jli' $i
done

for i in lib/lib*.so ; do
    [ -r "$i" ] || continue
    a= patchelf --set-rpath '$ORIGIN/../runtime/lib/amd64' $i
done

for i in lib/java3d-1.6/lib*.so lib/yafaray/lib*.so  ; do
    [ -r "$i" ] || continue
    a= patchelf --set-rpath '$ORIGIN:$ORIGIN/../../runtime/lib/amd64' $i
done
fi

chmod -v a+x runtime/bin/*

add_findreq_skiplist "$PRODUCTDIR/runtime/lib/amd64/libav*.so"

set_autoreq 'yes'

