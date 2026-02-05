#!/bin/sh

PKGNAME=max
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Быстрое и лёгкое приложение для общения и решения повседневных задач'
URL="https://max.ru/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

filename=$(eget -O- https://download.max.ru/linux/deb/dists/stable/main/binary-amd64/Packages \
  | grep '^Filename:' | head -n1 | cut -d' ' -f2 \
  | awk -F/ '{print $NF}' | sed 's/\.deb$//')

VERSION=$(echo "$filename" | sed 's/^MAX-//' | cut -d. -f1-3)

pkgtype=$(epm print info -p)
distr="$(epm print info -s)"
case $pkgtype in
    rpm)
        PKGURL="https://download.max.ru/linux/rpm/el/9/x86_64/${filename}.rpm"
        ;;
    *)
        PKGURL="https://download.max.ru/linux/deb/pool/main/m/max/${filename}.deb"
        ;;
esac

case $distr in
    alt)
        PKGURL="https://download.max.ru/linux/alt/x86_64/RPMS.max/max-${VERSION}-1.x86_64.rpm"
        ;;
esac

install_pkgurl
