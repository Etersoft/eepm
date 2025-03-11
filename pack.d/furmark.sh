#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

#FurMark_2.6.0.0_linux64.7z
BASENAME=$(basename $TAR .7z)
VERSION=$(echo $BASENAME | sed -e 's|FurMark_||' | sed -e 's|_linux64||')

erc unpack $TAR || fatal

mkdir -p opt/furmark
mv FurMark_linux64/* opt/furmark

# create desktop file
cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=FurMark
Comment=GPU Stress Test
Exec=FurMark_GUI
Icon=$PRODUCT
Type=Application
Categories=Graphics;
StartupNotify=true
EOF

# need writable log in /opt/furmark/
ln -s /var/tmp/_geexlab_log.txt opt/furmark/
ln -s /var/tmp/_furmark_log.txt opt/furmark/

# install icon
install_file ipfs://Qmf1Ced3UdH6ARezEwbf6FmAjqve4THZf1sbE6JUGBhitg /usr/share/pixmaps/$PRODUCT.png

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr opt || fatal

return_tar $PKGNAME.tar
