#!/bin/sh

PKGNAME=SMathStudioDesktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="SMath Studio from the official site"
URL="https://www.smath.com/ru-RU/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case "$(epm print info -d)" in
  AstraLinux*)
      PKGURL="https://www.smath.com/ru-RU/files/Download/BkAoH/SMathStudioDesktop.1_3_0_9126.Mono.x86_64.astra-orel.glibc2.24.AppImage"
      ;;
  *)
      PKGURL="https://www.smath.com/ru-RU/files/Download/cqSek/SMathStudioDesktop.1_3_0_9126.x86_64.ubuntu-22_04.glibc2.35.AppImage"
      ;;
esac

install_pkgurl
