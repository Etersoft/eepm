#!/bin/sh

PKGNAME=webdavmailrucloud
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="WebDAV emulator for Cloud.mail.ru / Yandex.Disk"
URL="https://github.com/yar229/WebDavMailRuCloud"

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://github.com/yar229/WebDavMailRuCloud/releases "WebDAVCloudMailRu-${VERSION}-dotNet6.zip") || fatal

epm pack --install $PKGNAME $PKGURL
