#!/bin/sh

PKGNAME=webdavmailrucloud
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="WebDAV emulator for Cloud.mail.ru / Yandex.Disk"
URL="https://github.com/yar229/WebDavMailRuCloud"

. $(dirname $0)/common.sh

dotnet=6
PKGURL=$(eget --list --latest https://github.com/yar229/WebDavMailRuCloud/releases "WebDAVCloudMailRu-${VERSION}-dotNet$dotnet.zip")

install_pack_pkgurl
