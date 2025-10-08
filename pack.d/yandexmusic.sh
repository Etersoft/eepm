#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar

# erc unpack /var/tmp/tmp.F8zrFHvurl/Yandex_Music_amd64_5.71.2.deb
# ERROR: Can't recognize type of /var/tmp/tmp.F8zrFHvurl/Yandex_Music_amd64_5.71.2.deb.
a='' ar -x $TAR
a='' tar xf "data.tar.xz"

# drop dirname with spaces
mv -v "opt/Яндекс Музыка" opt/yandex-music || fatal

# disable autoupdate
rm -v opt/yandex-music/resources/app-update.yml

# fix desktop file
subst 's|^Exec=.*|Exec=yandexmusic %U|' usr/share/applications/yandexmusic.desktop

erc pack $PKGNAME opt usr

return_tar $PKGNAME
