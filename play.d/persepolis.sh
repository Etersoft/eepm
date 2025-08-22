#!/bin/sh

PKGNAME=persepolis
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Persepolis is a download manager written in Python.'
URL="https://persepolisdm.github.io/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url https://github.com/persepolisdm/persepolis/ "${PKGNAME}_${VERSION}_all.deb")
else
    # Отрезаем последнюю цифру из версии для получения правильного тега. Например: 5.1.1.0 -> 5.1.1
    TAG_VERSION=$(echo "$VERSION" | sed 's/\.[0-9]*$//')
    PKGURL="https://github.com/persepolisdm/persepolis/releases/download/$TAG_VERSION/${PKGNAME}_${VERSION}_all.deb"
fi

install_pkgurl
