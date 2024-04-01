#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if echo "$TAR" | grep -q "WebDAVCloudMailRu-.*.zip" ; then
    erc "$TAR" || fatal
else
    fatal "We support only WebDAVCloudMailRu....zip"
fi

rm -v "$TAR"
VERSION="$(echo "$TAR" | sed -e 's|.*WebDAVCloudMailRu-||' -e 's|-.*||')"
mkdir opt
mv WebDAVCloudMailRu* opt/WebDAVCloudMailRu || fatal

PKG=webdavmailrucloud-$VERSION.tar
erc pack $PKG opt/WebDAVCloudMailRu

cat <<EOF >$PKG.eepm.yaml
name: $PRODUCT
group: Networking/File transfer
license: MIT
url: https://github.com/yar229/WebDavMailRuCloud
summary: WebDAV emulator for Cloud.mail.ru / Yandex.Disk
description: WebDAV emulator for Cloud.mail.ru / Yandex.Disk
EOF


return_tar $PKG
