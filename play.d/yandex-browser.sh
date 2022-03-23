#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=yandex-browser-beta

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Yandex browser from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=yandex-browser-beta

# epm uses eget to download * names
epm install "https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-beta/$(epm print constructname $PKGNAME "*" amd64 deb)"

# used in update-ffmpeg
epm install jq tar binutils

# install appropriate ffmpeg extra codecs
pack_ffmpeg() {
  SOURCE="usr/lib/chromium-browser/libffmpeg.so"
  DEST="/opt/yandex/browser-beta"
  mkdir -p .$DEST
  cp $SOURCE .$DEST
  CNAME=$(echo "$(basename $SUITABLE_URLS)" | sed -e "s|chromium|$PKGNAME|" -e "s|-0ubuntu.*|-1.tar|")
  tar cvf $CNAME ./$(dirname $DEST)
  epm --repack install $CNAME
}

[ -s /opt/yandex/browser-beta/update-ffmpeg ] || fatal "/opt/yandex/browser-beta/update-ffmpeg is missed"
SC=$(mktemp)
sed -e 's|install_ffmpeg &&|pack_ffmpeg &&|' < /opt/yandex/browser-beta/update-ffmpeg > $SC
. $SC
rm -f $SC

#echo
#echo '
#You can run
# # /opt/yandex/browser-beta/update-ffmpeg
#to download and install libffmpeg.so with proprietary codecs from chromium-codecs-ffmpeg-extra package
#'
