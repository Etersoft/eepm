#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=SweetHome3D

subst '1iConflicts:sweethome3d' $SPEC

subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: http://www.sweethome3d.com|" $SPEC
subst "s|^Summary:.*|Summary: An interior design application to draw house plans & arrange furniture|" $SPEC

# move package to /opt
ROOTDIR=$(basename $(find $BUILDROOT -mindepth 1 -maxdepth 1 -type d))
mkdir $BUILDROOT/opt
mv $BUILDROOT/$ROOTDIR $BUILDROOT/opt/$PRODUCT
subst "s|\"/$ROOTDIR/|\"/opt/$PRODUCT/|" $SPEC

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
Exec=/opt/$PRODUCT/SweetHome3D
Icon=sweethome3d
Terminal=false
Type=Application
StartupNotify=true
StartupWMClass=com-eteks-sweethome3d-SweetHome3D
Categories=Graphics;2DGraphics;3DGraphics;
MimeType=application/vnd.sh3d;
EOF
subst "s|%files|%files\n/usr/share/applications/$PRODUCT.desktop|" $SPEC
