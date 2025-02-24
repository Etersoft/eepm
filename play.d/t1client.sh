#!/bin/sh

PKGNAME=t1client-standalone
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="DSSL Trassir Client"
URL="https://confluence.trassir.com/pages/viewpage.action?pageId=36865118"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case "$(epm print info -p)" in
  rpm)
      PKGURL="https://ncloud.dssl.ru/s/SF7LcjPXa6oLbAN/download/t1client-standalone-13209.rpm"
      ;;
  *)
      PKGURL="https://ncloud.dssl.ru/s/F8sqrXwmpnb8Bj5/download/t1client-standalone-4.5.28.0-1238402-Release.deb"
      ;;
esac

case "$(epm print info -s)" in
  alt)
      PKGURL="https://ncloud.dssl.ru/s/F8sqrXwmpnb8Bj5/download/t1client-standalone-4.5.28.0-1238402-Release.deb"
      ;;
esac

install_pkgurl
