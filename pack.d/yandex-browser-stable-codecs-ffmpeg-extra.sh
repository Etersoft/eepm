#!/bin/sh -x

UPDATEFFMPEG="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

[ -x "$UPDATEFFMPEG" ] || fatal "$UPDATEFFMPEG is missed"

CURDIR="$(pwd)"
PRODUCTDIR="$(dirname "$UPDATEFFMPEG")"
BASEPKGNAME=yandex-browser-stable

if echo "$PRODUCT" | grep -q "yandex-browser-beta" ; then
    BASEPKGNAME=yandex-browser-beta
fi

# used in update-ffmpeg
epm install --skip-installed jq tar binutils || exit

# install ffmpeg extra codecs
pack_ffmpeg() {
  SOURCE="usr/lib/chromium-browser/libffmpeg.so"
  DEST="$PRODUCTDIR"
  mkdir -p .$DEST
  cp $SOURCE .$DEST
  CNAME="$CURDIR/$(echo "$(basename $SUITABLE_URLS)" | sed -e "s|chromium|$BASEPKGNAME|" -e "s|-[0-9]*ubuntu.*|-1.tar|")" #"
  a='' tar cf $CNAME .$(dirname $DEST)
  return_tar $CNAME
  # exit from update-ffmpeg script here
  exit
}

URL="https://browser-resources.s3.yandex.net/linux/codecs.json"

# download ffmpeg with upstream script update-ffmpeg but with our pack_ffmpeg function
SC=$(mktemp)
trap "rm -f $SC" EXIT
sed -e 's|install_ffmpeg &&|pack_ffmpeg \&\&|' \
    -e 's|wget -q-O|epm tool eget -q -O|' \
    -e 's|wget -O|epm tool eget -O |' \
    -e "s|CODECS_JSON_URL='https://browser-resources.s3.yandex.net/linux/codecs.json'|CODECS_JSON_URL='$URL'|" < $UPDATEFFMPEG > $SC
. $SC

