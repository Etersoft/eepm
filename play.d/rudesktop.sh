#!/bin/sh

PKGNAME=rudesktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="RuDesktop for Linux from the official site"
URL="https://rudesktop.ru/"

# change installed package name
case "$(epm print info -s)" in
  astra)
      PKGNAME=rudesktop-astra
      ;;
esac

. $(dirname $0)/common.sh

warn_version_is_not_supported

repack=''
# change package name for downloading
case "$(epm print info -s)" in
  alt)
      PKGNAME=rudesktop-alt
      repack='--repack'
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

PKGURL="https://rudesktop.ru/download/$PKGNAME-amd64.$pkgtype"
epm install $repack $PKGURL
