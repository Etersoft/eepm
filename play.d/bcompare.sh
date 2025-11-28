#!/bin/sh

PKGNAME=bcompare
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Beyond Compare 5: Compare, sync, and merge files and folders for Linux from the official site"
URL="https://www.scootersoftware.com/"

. $(dirname $0)/common.sh


case "$(epm print info -p)" in
  rpm)
      PKGMASK="$PKGNAME-${VERSION}.x86_64.rpm"
      ;;
  *)
      PKGMASK="$PKGNAME-${VERSION}_amd64.deb"
      ;;
esac

# https://www.scootersoftware.com/files/bcompare-5.1.6.31527_amd64.deb
# https://www.scootersoftware.com/files/bcompare-5.1.6.31527.x86_64.rpm
if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://www.scootersoftware.com/download "$PKGMASK")"
else
    PKGURL="https://www.scootersoftware.com/files/$PKGMASK"
fi

install_pkgurl
