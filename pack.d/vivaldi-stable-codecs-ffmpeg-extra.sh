#!/bin/sh -x

UPDATEFFMPEG="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

[ -x "$UPDATEFFMPEG" ] || fatal "$UPDATEFFMPEG is missed"

CURDIR=$(pwd)
PRODUCTDIR="$(dirname $UPDATEFFMPEG)"
BASEPKGNAME=vivaldi-stable

if echo "$PRODUCT" | grep -q "vivaldi-snapshot" ; then
    BASEPKGNAME=vivaldi-snapshot
fi

VIVALDI_VERSION=$(epm print version for package $BASEPKGNAME) || fatal

# used in update-ffmpeg
epm install --skip-installed tar binutils || exit
epm assure awk gawk || exit

# install ffmpeg extra codecs
pack_ffmpeg() {
  SOURCE="usr/lib/chromium-browser/libffmpeg.so"
  DEST="$PRODUCTDIR"
  mkdir -p .$DEST
  cp $SOURCE .$DEST/libffmpeg.so.${VIVALDI_VERSION%\.*\.*}
  CNAME="$CURDIR/$(echo "$(basename $SUITABLE_URLS)" | sed -e "s|chromium|$BASEPKGNAME|" -e "s|-0ubuntu.*|-1.tar|")" #"
  a='' tar cf $CNAME .$(dirname $DEST)
  return_tar $CNAME
  exit
}


SC=tmp_updateffmpeg
a='' awk 'BEGIN{desk=0}{ if(/^.*--system.*/&&desk==0){desk++} ; if (desk==0) {print} }' < $UPDATEFFMPEG > $SC
. $SC

epm tool eget $FFMPEG_URL_DEB || exit
SUITABLE_URLS=$FFMPEG_URL_DEB
a='' ar -x *.deb || exit
a='' tar xf "data.tar.xz" || exit
pack_ffmpeg
