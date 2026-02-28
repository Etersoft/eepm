#!/bin/sh

PKGNAME=vagrant
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Build and distribute virtualized development environments"
URL="https://vagrantup.com"

. $(dirname $0)/common.sh

BASEURL="https://hashicorp-releases.yandexcloud.net/vagrant"

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- "$BASEURL/" 2>/dev/null | grep -o 'vagrant/[0-9][0-9.]*' | head -1 | sed 's|vagrant/||')
    [ -n "$VERSION" ] || fatal "Can't get latest version"
fi

case "$(epm print info -p)" in
    rpm)
        PKGURL="$BASEURL/${VERSION}/vagrant-${VERSION}-1.x86_64.rpm"
        ;;
    *)
        PKGURL="$BASEURL/${VERSION}/vagrant_${VERSION}-1_amd64.deb"
        ;;
esac

install_pkgurl
