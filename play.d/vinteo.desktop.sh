#!/bin/sh

PKGNAME=vinteo-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Client for Vinteo videoconferencing server"
URL="https://vinteo.com"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

[ "$VERSION" = "*" ] && VERSION="$(eget -q -O- "https://vinteo.ru/download/vinteo-desktop/" | grep -o -m 1 "Версия продукта [0-9].[0-9].[0-9]" | awk '{print $3}' )"
[ -n "$VERSION" ] || fatal "Can't get version"

# use rpm, but not for ALT
[ "$(epm print info -p)" = "rpm" ] && [ "$(epm print info -s)" != "alt" ] && pkgtype=rpm

case "$(epm print info -d)" in
  AstraLinux*)
      PKGURL="https://download.vinteo.com/VinteoClient/linux/$VERSION/astralinux/vinteo-desktop-$VERSION-$arch.$pkgtype"
      ;;
  *)
      PKGURL="https://download.vinteo.com/VinteoClient/linux/$VERSION/vinteo-desktop-$VERSION-$arch.$pkgtype"
      ;;
esac

install_pkgurl
