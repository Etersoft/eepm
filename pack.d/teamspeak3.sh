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

# pack libwebp.so.6 from ALT Linux
eget https://git.altlinux.org/tasks/177836/build/200/x86_64/rpms/libwebp6-0.5.2-alt2.x86_64.rpm
rpm2cpio libwebp6-0.5.2-alt2.x86_64.rpm | cpio -idmv
cp usr/lib64/* opt/$PRODUCT
rm libwebp6-0.5.2-alt2.x86_64.rpm

# TeamSpeak3-Client-linux_amd64-3.6.0.run
VERSION="$(echo $TAR | sed -e 's|.*-||' -e 's|\..*||')"
PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Video
license: Proprietary
url: http://www.teamspeak.com
summary: TeamSpeak is software for quality voice communication via the Internet
description: eamSpeak is software for quality voice communication via the Internet
EOF

return_tar $PKGNAME.tar
