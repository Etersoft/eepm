#!/bin/sh

PKGNAME=rudesktop
SUPPORTEDARCHES="x86_64"
DESCRIPTION="RuDesktop for Linux from the official site"

. $(dirname $0)/common.sh

case "$(epm print info -d)" in
  AstraLinux*)
      PKGNAME=rudesktop-astra
      ;;
esac

URL=$(epm tool eget --list --latest https://rudesktop.ru/ $PKGNAME-1*.deb)
epm install $URL
