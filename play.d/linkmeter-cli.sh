#!/bin/sh

PKGNAME=linkmeter-cli
SUPPORTEDARCHES="x86_64 aarch64"
DESCRIPTION="Российский сервис тестирования скорости интернета"
URL="https://linkmeter.net/software.html"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch=$(epm print info -a)

VERSION="1.0"
PKGURL="https://api.linkmeter.net/linkmeter-cli_${arch}"

install_pack_pkgurl $VERSION
