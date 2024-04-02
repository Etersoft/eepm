#!/bin/sh

PKGNAME=yandex-messenger
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Yandex Messenger is designed for communication: send text messages, make audio and video calls in private and group chats, subscribe to and create channels."
URL="https://yandex.ru/support/messenger/index.html"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# they publish it on Yandex Disk only (without direct download)
PKGURL="ipfs://Qma7e4MpopXpeoNnTsCXxx92q1oTrgJmz1aHjecvcEBNWx?filename=Yandex_Messenger_2.155.0_amd64.deb"

install_pkgurl
