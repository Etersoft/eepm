#!/bin/sh

PKGNAME=rudesktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="RuDesktop for Linux from the official site"
URL="https://rudesktop.ru/"

. $(dirname $0)/common.sh

#case "$(epm print info -s)" in
#  astra)
#      PKGNAME=rudesktop-astra
#      ;;
#  alt)
#      PKGNAME=rudesktop-alt
#      ;;
#  osnova)
#      PKGNAME=rudesktop-osnova
#      ;;
#esac

case "$(epm print info -s)" in
  alt)
      PKGNAME=rudesktop-alt
      ;;
  *)
      PKGNAME=rudesktop
      ;;
esac

case "$(epm print info -p)" in
  rpm)
      pkgtype=rpm
      ;;
  *)
      pkgtype=deb
      ;;
esac

if [ "$VERSION" != "*" ] ; then
    PKGURL="https://storage.rudesktop.ru/download/$PKGNAME-$VERSION-amd64.$pkgtype"
else
    PKGURL="$(eget --list --latest https://rudesktop.ru/downloads/ "$PKGNAME-*-amd64.$pkgtype")"
fi

install_pkgurl

echo
echo "Note: run
# serv $PKGNAME on
to enable and start $PKGNAME system service
Use
/usr/bin/rudesktop --rendezvous DOMAIN
to set the domain if needed."
