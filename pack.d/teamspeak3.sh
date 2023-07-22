#!/bin/sh

TAR="$1"
#VERSION="$2"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

mkdir -p opt/$PRODUCT && cd opt/$PRODUCT || fatal
sh $TAR --tar xvf || exit
chmod a+rX -R *

# Remove bundled libraries (embedded Qt needs libevent-2.1.so.7
false && rm -rfv qt.conf *.so* \
      platforms xcbglintegrations \
      iconengines imageformats \
      qtwebengine_locales \
      sqldrivers \
      QtWebEngineProcess \
      ts3client_runscript.sh

rm -v update
cd - >/dev/null


# TeamSpeak3-Client-linux_amd64-3.6.0.run
VERSION="$(echo $TAR | sed -e 's|.*-||' -e 's|\..*||')"
PKGNAME=$PRODUCT-$VERSION

erc a $PKGNAME.tar opt/$PRODUCT

return_tar $PKGNAME.tar
