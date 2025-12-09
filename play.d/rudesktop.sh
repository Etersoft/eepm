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
      package=rudesktop-alt
      ;;
  *)
      package=rudesktop
      ;;
esac

case "$(epm print info -p)" in
  rpm)
      pkgtype=x86_64.rpm
      ;;
  *)
      pkgtype=amd64.deb
      ;;
esac

if [ "$VERSION" != "*" ] ; then
    PKGURL="https://storage.rudesktop.ru/download/$package-$VERSION-$pkgtype"
else
    PKGURL="$(eget --list --latest https://rudesktop.ru/downloads/ "$package-*-$pkgtype")"
fi

install_pkgurl || exit

echo
echo "Note: run
# serv $PKGNAME on
to enable and start $PKGNAME system service
Use
/usr/bin/rudesktop --rendezvous DOMAIN
to set the domain if needed."
