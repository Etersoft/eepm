#!/bin/sh -x

FFMPEGDEB="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

[ -s "$FFMPEGDEB" ] || fatal "$FFMPEGDEB is missed"

CURDIR=$(pwd)

# TODO: set via args?
PRODUCTDIR=/opt/chromium-browser
PKGNAME=chromium-codecs-ffmpeg-extra
BASEPKGNAME="chromium"

# used in update-ffmpeg
epm install --skip-installed tar binutils || exit

# install ffmpeg extra codecs
pack_ffmpeg() {
  SOURCE="usr/lib/chromium-browser/libffmpeg.so"
  DEST="$PRODUCTDIR"
  mkdir -p .$DEST
  cp $SOURCE .$DEST/libffmpeg.so
  CNAME="$CURDIR/$(echo "$(basename $FFMPEGDEB)" | sed -e "s|chromium|$BASEPKGNAME|" -e "s|-0ubuntu.*|-1.tar|" )" #"
  a='' tar cf $CNAME .$(dirname $DEST)
  return_tar $CNAME
  exit
}

DDIR=$(mktemp -d)
trap "rm -fr $DDIR" EXIT
cd $DDIR || fatal
# direct unpack deb
a='' ar -x $FFMPEGDEB
a='' tar xf "data.tar.xz"
pack_ffmpeg
