#!/bin/sh

PKGNAME=rudesktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="RuDesktop for Linux from the official site"

case "$(epm print info -d)" in
  AstraLinux*)
      PKGNAME=rudesktop-astra
      ;;
esac

. $(dirname $0)/common.sh

PKGURL=$(epm tool eget --list --latest https://rudesktop.ru/ $PKGNAME-$VERSION.deb)
epm install $PKGURL
