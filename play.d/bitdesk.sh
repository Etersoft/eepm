#!/bin/sh

PKGNAME=bitdesk
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="BitDesk (Доступ 365) — remote desktop access and control"
URL="https://dostup365.ru"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info -a)"

pkgtype=rpm
[ "$(epm print info -p)" = "deb" ] && pkgtype=deb

PKGURL="https://dostup365.ru/download/$PKGNAME-$arch.$pkgtype"

install_pkgurl || exit

cat <<EOF

Note: run
# serv bitdesk on
to enable needed bitdesk system service (daemon)
EOF
