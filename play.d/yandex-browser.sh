#!/bin/sh

PKGNAME=yandex-browser-stable
PRODUCTDIR=/opt/yandex/browser
DESCRIPTION="Yandex browser from the official site"

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    epm remove $PKGNAME-codecs-ffmpeg-extra
    exit
fi

. $(dirname $0)/common.sh

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=yandex-browser-beta

# epm uses eget to download * names
epm install "https://repo.yandex.ru/yandex-browser/deb/pool/main/y/$PKGNAME/$(epm print constructname $PKGNAME "*" amd64 deb)" || exit

# used in update-ffmpeg
epm install --skip-installed jq tar binutils || exit

# install appropriate ffmpeg extra codecs
pack_ffmpeg() {
  SOURCE="usr/lib/chromium-browser/libffmpeg.so"
  DEST="$PRODUCTDIR"
  mkdir -p .$DEST
  cp $SOURCE .$DEST
  CNAME=$(echo "$(basename $SUITABLE_URLS)" | sed -e "s|chromium|$PKGNAME|" -e "s|-0ubuntu.*|-1.tar|")
  a='' tar cvf $CNAME ./$(dirname $DEST)
  epm --repack install $CNAME
}

# download ffmpeg with upstream script but with our pack_ffmpeg function
[ -s $PRODUCTDIR/update-ffmpeg ] || fatal "$PRODUCTDIR/update-ffmpeg is missed"
SC=$(mktemp)
sed -e 's|install_ffmpeg &&|pack_ffmpeg &&|' < $PRODUCTDIR/update-ffmpeg > $SC
. $SC
rm -f $SC
