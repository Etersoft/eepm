#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

# ZWCAD_Viewer_Beta.tar.gz
BASENAME=$(basename $1 .tar.gz)
mkdir -p opt/ZWCADViewer
mkdir -p usr/
mkdir -p etc/xdg/menus/applications-merged

erc unpack $TAR || fatal

RUN_NAME=$(echo ZWCAD*.run)

# unpacking .run archive
sh $RUN_NAME --target temp/zwcad-viewer
mv ZWCADViewer opt/zwcad-viewer

# move file in right directories
mv .local/share/ usr/
mv .config/menus/applications-merged/xdg-desktop-menu-dummy.menu etc/xdg/menus/applications-merged/

# fix startup file
mv "opt/zwcad-viewer/ZWCADRUN.sh" opt/zwcad-viewer/$PRODUCT
subst 's|$HOME/ZWCADViewer|/opt/zwcad-viewer|' opt/zwcad-viewer/$PRODUCT

# setup icon
mkdir -p usr/share/icons/hicolor/512x512/apps
mv opt/zwcad-viewer/ZWCAD.png usr/share/icons/hicolor/512x512/apps/

# delete unneeded files
find usr/share/mime -type f ! -wholename 'usr/share/mime/application/dwg.xml' ! -wholename 'usr/share/mime/application/dxf.xml' \
! -wholename 'usr/share/mime/packages/ZWCAD-mimetypes.xml' ! -wholename 'usr/share/mime/image/x-dwg.xml' -exec rm {} +
rm usr/share/applications/defaults.list

# fix desktop file
sed -i 's/^Icon=.*/Icon=ZWCAD.png/' usr/share/applications/Ribbonsoft-ZWCADViewer.desktop
sed -i 's/^Exec=.*/Exec=zwcad-viewer %F/' usr/share/applications/Ribbonsoft-ZWCADViewer.desktop

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt/$PRODUCT usr etc || fatal

return_tar $PKGNAME.tar
