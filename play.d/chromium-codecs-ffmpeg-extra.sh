#!/bin/sh

BRANCH=stable
PRODUCTDIR=/opt/chromium-browser
DESCRIPTION=''

BASEPKGNAME=chromium
PKGNAME=chromium-$BRANCH-codecs-ffmpeg-extra
SUPPORTEDARCHES="x86_64"

# copied from /opt/vivaldi/update-ffmpeg
FFMPEG_VERSION_DEB=103.0.5060.134-0ubuntu0.18.04.1 # Internal FFMpeg version = 107578
FFMPEG_URL_DEB=https://launchpadlibrarian.net/613925272/chromium-codecs-ffmpeg-extra_${FFMPEG_VERSION_DEB}_amd64.deb

. $(dirname $0)/common.sh

epm install --skip-installed tar binutils || exit
epm assure awk gawk || exit

# install ffmpeg extra codecs
pack_ffmpeg() {
  SOURCE="usr/lib/chromium-browser/libffmpeg.so"
  DEST="$PRODUCTDIR"
  mkdir -p .$DEST
  cp $SOURCE .$DEST/libffmpeg.so
  CNAME="$(echo "$(basename $FFMPEG_URL_DEB)" | sed -e "s|chromium|$BASEPKGNAME|" -e "s|-0ubuntu.*|-1.tar|")" #"
  a='' tar cf $CNAME .$(dirname $DEST)
  epm --repack install $CNAME
}

DDIR=$(mktemp -d)
cd $DDIR || fatal
epm tool eget $FFMPEG_URL_DEB || fatal
a='' ar -x *.deb
a='' tar xf "data.tar.xz"
pack_ffmpeg
rm -rf $DDIR
rm -f $SC
