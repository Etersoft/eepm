#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

erc --here unpack $TAR || fatal

RUN_NAME=$(echo ZWCAD*.run)

# unpacking .run archive (erc can't handle makeself .run correctly)
chmod +x $RUN_NAME
./$RUN_NAME --noexec --target zwcad-contents || fatal

# move app files to opt
mkdir -p opt/$PRODUCT
mv zwcad-contents/* opt/$PRODUCT/

# fix startup script
mv opt/$PRODUCT/ZWCADRUN.sh opt/$PRODUCT/$PRODUCT
subst 's|$HOME/ZWCADViewer|/opt/zwcad-viewer|' opt/$PRODUCT/$PRODUCT
chmod 755 opt/$PRODUCT/$PRODUCT

# remove linked with missed libs
rm -fv opt/$PRODUCT/libqgsttools_p.so.*

# remove install/uninstall scripts and xdg helpers
rm -f opt/$PRODUCT/ZWCADINSTALL.sh opt/$PRODUCT/ZWCADINSTALL.sh~
rm -f opt/$PRODUCT/ZWCADSETUP.sh
rm -f opt/$PRODUCT/Uninst.sh opt/$PRODUCT/Uninst.sh~
rm -rf opt/$PRODUCT/xdg

# setup icon
mkdir -p usr/share/icons/hicolor/512x512/apps
mv opt/$PRODUCT/ZWCAD.png usr/share/icons/hicolor/512x512/apps/

# create desktop file
mkdir -p usr/share/applications
cat <<EOF > usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=ZWCAD Viewer
GenericName=CAD Software
Comment=Read DWG and DXF files.
Exec=/opt/$PRODUCT/$PRODUCT %F
Terminal=false
Type=Application
Icon=ZWCAD.png
Categories=Application;Graphics;VectorGraphics;Engineering;Construction;2DGraphics;
MimeType=application/dxf;application/dwg
EOF

# create mime type definitions
mkdir -p usr/share/mime/packages
cat <<EOF > usr/share/mime/packages/zwcad-mimetypes.xml
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/dxf">
    <comment xml:lang="en">CAD Drawing</comment>
    <glob pattern="*.dxf"/>
  </mime-type>
  <mime-type type="application/dwg">
    <comment xml:lang="en">CAD Drawing</comment>
    <glob pattern="*.dwg"/>
  </mime-type>
</mime-info>
EOF

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt/$PRODUCT usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Engineering
license: Proprietary
url: https://www.zwsoft.com/
summary: ZWCAD Viewer for viewing DWG/DXF files
description: ZWCAD Viewer is a free viewer for DWG and DXF files.
EOF

return_tar $PKGNAME.tar
