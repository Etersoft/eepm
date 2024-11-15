#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

PRODUCT="svp4"
# svp4-linux.4.6.263
VERSION="$(basename "$TAR" .tar.bz2 | grep -oP '\d+\.\d+(\.\d+)?')"

mkdir -p opt/svp4
erc $TAR

mkdir installer
LANG=C grep --only-matching --byte-offset --binary --text $'7z\xBC\xAF\x27\x1C' "svp4-linux-64.run" |
	cut -f1 -d: |
	while read ofs; do
		dd if="svp4-linux-64.run" bs=1M iflag=skip_bytes status=none skip="${ofs}" of="installer/bin-${ofs}.7z"
	done
for f in "installer/"*.7z; do
		7z -bd -bb0 -y x -o"extracted/" "${f}" || true
done

mv extracted/* opt/svp4/

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
