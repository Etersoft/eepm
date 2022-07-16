#!/bin/sh

BRANCH=stable
PRODUCTDIR=/opt/vivaldi
DESCRIPTION=''

if [ "$2" = "snapshot" ] ; then
    BRANCH=snapshot
    #PRODUCTDIR=$PRODUCTDIR-$BRANCH
fi

BASEPKGNAME=vivaldi-$BRANCH
PRODUCTALT="stable snapshot"
PKGNAME=vivaldi-$BRANCH-codecs-ffmpeg-extra
SUPPORTEDARCHES="x86_64"

. $(dirname $0)/common.sh

VIVALDI_VERSION=$(epm print version for package vivaldi-stable) || fatal

epm install --skip-installed tar binutils || exit
epm assure awk gawk || exit

# install ffmpeg extra codecs
pack_ffmpeg() {
  SOURCE="usr/lib/chromium-browser/libffmpeg.so"
  DEST="$PRODUCTDIR"
  mkdir -p .$DEST
  cp $SOURCE .$DEST/libffmpeg.so.${VIVALDI_VERSION%\.*\.*}
  CNAME="$(echo "$(basename $SUITABLE_URLS)" | sed -e "s|chromium|$BASEPKGNAME|" -e "s|-0ubuntu.*|-1.tar|")" #"
  a='' tar cf $CNAME .$(dirname $DEST)
  epm --repack install $CNAME
}

# download ffmpeg with upstream script update-ffmpeg but with our pack_ffmpeg function
[ -s $PRODUCTDIR/update-ffmpeg ] || fatal "$PRODUCTDIR/update-ffmpeg is missed"
SC=$(mktemp)
a='' awk 'BEGIN{desk=0}{ if(/^.*--system.*/&&desk==0){desk++} ; if (desk==0) {print} }' < $PRODUCTDIR/update-ffmpeg > $SC
. $SC
DDIR=$(mktemp -d)
cd $DDIR || fatal
epm tool eget $FFMPEG_URL_DEB
SUITABLE_URLS=$FFMPEG_URL_DEB
a='' ar -x *.deb
a='' tar xf "data.tar.xz"
pack_ffmpeg
rm -rf $DDIR
rm -f $SC
