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

PKGNAME=webdavmailrucloud-$VERSION.tar
erc pack $PKGNAME opt/WebDAVCloudMailRu

return_tar $PKGNAME
