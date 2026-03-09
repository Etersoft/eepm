#!/bin/sh

PKGNAME=vagrant
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Build and distribute virtualized development environments"
URL="https://vagrantup.com"

. $(dirname $0)/common.sh

BASEURL="https://releases.hashicorp.com/vagrant"

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- "$BASEURL/" 2>/dev/null | grep -o 'vagrant/[0-9][0-9.]*' | head -1 | sed 's|vagrant/||')
    [ -n "$VERSION" ] || fatal "Can't get latest version"
fi

case "$(epm print info -p)" in
    rpm)
        PKGURL="$BASEURL/${VERSION}/vagrant-${VERSION}-${RELEASE}.x86_64.rpm"
        ;;
    *)
        PKGURL="$BASEURL/${VERSION}/vagrant_${VERSION}-${RELEASE}_amd64.deb"
        ;;
esac

install_pkgurl
