#!/bin/sh

PKGNAME=webdavmailrucloud
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="WebDAV emulator for Cloud.mail.ru / Yandex.Disk"
URL="https://github.com/yar229/WebDavMailRuCloud"

. $(dirname $0)/common.sh

dotnet=6
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/yar229/WebDavMailRuCloud/" "WebDAVCloudMailRu-.${VERSION}-dotNet$dotnet.zip")
else
    PKGURL="https://github.com/yar229/WebDavMailRuCloud/releases/download/$VERSION/WebDAVCloudMailRu-${VERSION}-dotNet$dotnet.zip"
fi

install_pack_pkgurl
