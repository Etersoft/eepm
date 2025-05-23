#!/bin/sh

PKGNAME=rupost-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="RuPost Desktop Personal from the official site"
URL="https://www.rupost.ru/desktop"

. $(dirname $0)/common.sh

warn_version_is_not_supported


# Check https://www.rupost.ru/desktop/#desktop-download for updates

case "$(epm print info -p)" in
  rpm)
      PKGURL="https://download.workspad.com/external/link/rupost-desktop-122-0-188-rpm"
      PKGURL="ipfs://QmWS1G6zdwfj6R7SwRc3rqc2d918eDeY8cxoW2TteLMH1k?filename=rupost-desktop-122.0.188-1.x86_64.rpm"
      ;;
  *)
      PKGURL="https://download.workspad.com/external/link/rupost-desktop-122-0-188-deb"
      PKGURL="ipfs://QmR6dBR4P1me7xWxyFFihmufqjbkuNqpKSXJEYDLLLDSdN?filename=rupost-desktop-122.0.188.ru.linux-x86_64.deb"
      ;;
esac

case "$(epm print info -s)" in
  alt)
      PKGURL="https://download.workspad.com/external/link/rupost-desktop-122-0-188-alt"
      PKGURL="ipfs://QmPqunXrQRJnoMaeizQgfwETu2uRPLVcPxKJ5iuKym4Tuu?filename=rupost-desktop-122.0.188-alt1.x86_64.rpm"
      ;;
esac

install_pkgurl
