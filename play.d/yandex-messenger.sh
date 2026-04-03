#!/bin/sh

PKGNAME=yandex-messenger
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Yandex Messenger (Wine) from the official site"
URL="https://360.yandex.ru/business/messenger/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

[ "$VERSION" = "*" ] && VERSION="1.0"

# https://download.messenger.yandex.ru/desktop/latest?platform=win
PKGURL="https://chat-app.s3.yandex.net/chats/aldebaran64/Yandex_Messenger_Setup.exe"

install_pack_pkgurl $VERSION
