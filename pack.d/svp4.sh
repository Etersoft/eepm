#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

PRODUCT="svp4"
# svp4-linux.4.6.263
VERSION="$(basename "$TAR" .tar.bz2 | grep -oP '\d+\.\d+(\.\d+)?')"

mkdir -p opt/svp4
erc --here $TAR

chmod +x svp4-linux.run
# use unshare -rn to block network: installer hangs on cdn.svp-team.com requests
unshare -rn ./svp4-linux.run --installDefault --platform minimal --targetDir "$(pwd)/opt/svp4"

# Drop bundled pythonqt for avoid dependency on python 3.8
rm opt/svp4/extensions/libPythonQt.so

# Drop svptube for avoid dependency on python 3.8
rm opt/svp4/extensions/libsvptube.so
rm -r opt/svp4/extensions/tube

# Drop installer metadata and maintenance tool
rm -rf opt/svp4/installerResources
rm -f opt/svp4/installer.dat opt/svp4/components.xml opt/svp4/network.xml
rm -f opt/svp4/svp4-maintenance opt/svp4/svp4-maintenance.dat opt/svp4/svp4-maintenance.dat.backup opt/svp4/svp4-maintenance.ini
rm -f opt/svp4/InstallationLog.txt
rm -f opt/svp4/add-menuitem.sh opt/svp4/remove-menuitem.sh

PKGNAME=$PRODUCT-$VERSION

erc a $PKGNAME.tar opt

cat <<EOF >$PRODUCT.eepm.yaml
name: $PRODUCT
group: Video
license: LicenseRef-custom
url: https://www.svp-team.com/wiki/SVP:Linux
summary: SmoothVideo Project 4 (SVP4)
description: SVP converts any video to 60 fps (and even higher) and performs this in real time right in your favorite video player.
EOF

return_tar $PKGNAME.tar
