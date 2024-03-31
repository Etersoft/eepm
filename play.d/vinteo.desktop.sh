#!/bin/sh

PKGNAME=vinteo.desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Client for Vinteo videoconferencing server"
URL="https://vinteo.com"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

[ "$VERSION" = "*" ] && VERSION="$(eget --list --latest "https://download.vinteo.com/VinteoClient/linux/3.*" | xargs basename)"
[ -n "$VERSION" ] || fatal "Can't get version"

# use rpm, but not for ALT
[ "$(epm print info -p)" = "rpm" ] && [ "$(epm print info -s)" != "alt" ] && pkgtype=rpm

case "$(epm print info -d)" in
  AstraLinux*)
      PKGURL="https://download.vinteo.com/VinteoClient/linux/$VERSION/astralinux/Vinteo.Desktop-$VERSION-$arch.$pkgtype"
      ;;
  *)
      PKGURL="https://download.vinteo.com/VinteoClient/linux/$VERSION/Vinteo.Desktop-$VERSION-$arch.$pkgtype"
      ;;
esac

install_pkgurl
