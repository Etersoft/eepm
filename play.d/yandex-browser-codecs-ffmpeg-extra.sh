#!/bin/sh

BRANCH=stable
PRODUCTDIR=/opt/yandex/browser
DESCRIPTION=''

if [ "$2" = "beta" ] ; then
    BRANCH=beta
    PRODUCTDIR=/opt/yandex/browser-$BRANCH
fi

PRODUCTALT="stable beta"
BASEPKGNAME=yandex-browser-$BRANCH
PKGNAME=yandex-browser-$BRANCH-codecs-ffmpeg-extra
SUPPORTEDARCHES="x86_64"

. $(dirname $0)/common.sh

# used in update-ffmpeg
epm install --skip-installed jq tar binutils || exit

# install ffmpeg extra codecs
pack_ffmpeg() {
  SOURCE="usr/lib/chromium-browser/libffmpeg.so"
  DEST="$PRODUCTDIR"
  mkdir -p .$DEST
  cp $SOURCE .$DEST
  CNAME="$(echo "$(basename $SUITABLE_URLS)" | sed -e "s|chromium|$BASEPKGNAME|" -e "s|-0ubuntu.*|-1.tar|")" #"
  a='' tar cf $CNAME .$(dirname $DEST)
  epm --repack install $CNAME
  # exit from update-ffmpeg script here
  exit
}

# download ffmpeg with upstream script update-ffmpeg but with our pack_ffmpeg function
[ -s $PRODUCTDIR/update-ffmpeg ] || fatal "$PRODUCTDIR/update-ffmpeg is missed"
SC=$(mktemp)
sed -e 's|install_ffmpeg &&|pack_ffmpeg \&\&|' -e 's|wget -q-O|epm tool eget -q -O-|' < $PRODUCTDIR/update-ffmpeg > $SC
. $SC
rm -f $SC
