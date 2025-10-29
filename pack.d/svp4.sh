#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

PRODUCT="svp4"
# svp4-linux.4.6.263
VERSION="$(basename "$TAR" .tar.bz2 | grep -oP '\d+\.\d+(\.\d+)?')"

# mkdir -p installer
# echo "Finding 7z archives in installer..."
# LANG=C grep --only-matching --byte-offset --binary --text $'7z\xBC\xAF\x27\x1C' "svp4-linux-64.run" |
#     cut -f1 -d: |
#     while read ofs; do
#         dd if="svp4-linux-64.run" bs=1M iflag=skip_bytes status=none skip="${ofs}" of="installer/bin-${ofs}.7z"
#     done
#
# echo "Extracting 7z archives from installer..."
# for f in "installer/"*.7z; do
#     7z -bd -bb0 -y x -o"extracted/" "${f}" || true
# done

mkdir -p opt/svp4
erc $TAR

chmod +x svp4-linux.run
./svp4-linux.run --installDefault --targetDir "$(pwd)/opt/svp4"

# Drop bundled pythonqt for avoid dependency on python 3.8
rm opt/svp4/extensions/libPythonQt.so

# Drop svptube for avoid dependency on python 3.8
rm opt/svp4/extensions/libsvptube.so
rm -r opt/svp4/extensions/tube

# Drop installer source and bundled dependency
rm -r opt/svp4/installerResources
rm -r opt/svp4/mpv
rm -r opt/svp4/python
rm opt/svp4/qt6.conf
find opt/svp4/libs/ -mindepth 1 -maxdepth 1 ! -name 'libmediainfo.so.0' -exec rm -rf {} +

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
