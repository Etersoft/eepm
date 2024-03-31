#!/bin/sh

PKGNAME=rudesktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="RuDesktop for Linux from the official site"
URL="https://rudesktop.ru/"

pkgname="$PKGNAME"

# FIXME: uses global epm
# change package name (like on the site)
case "$(epm print info -s)" in
  astra)
      PKGNAME=rudesktop-astra
      ;;
  alt)
      pkgname=rudesktop-alt
      ;;
  osnova)
      PKGNAME=rudesktop-astra
      pkgname=rudesktop-osnova
      ;;
esac

. $(dirname $0)/common.sh

warn_version_is_not_supported

case "$(epm print info -p)" in
  rpm)
      pkgtype=rpm
      ;;
  *)
      pkgtype=deb
      ;;
esac

PKGURL="https://rudesktop.ru/download/$PKGNAME-amd64.$pkgtype"
install_pkgurl

echo
echo "Note: run
# serv $PKGNAME on
to enable and start $PKGNAME system service
Use
/usr/bin/rudesktop --rendezvous DOMAIN
to set the domain if needed.
"
