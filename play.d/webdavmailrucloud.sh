#!/bin/sh

PKGNAME=webdavmailrucloud
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="WebDAV emulator for Cloud.mail.ru / Yandex.Disk"
URL="https://github.com/yar229/WebDavMailRuCloud"

. $(dirname $0)/common.sh

dotnet=6
PKGURL=$(get_github_url "https://github.com/yar229/WebDavMailRuCloud/" "WebDAVCloudMailRu-${VERSION}-dotNet$dotnet.zip")

install_pack_pkgurl
