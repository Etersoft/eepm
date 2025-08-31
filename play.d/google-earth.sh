#!/bin/sh

PKGNAME=google-earth-pro-stable
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="3D interface to explore the globe, terrain, streets, buildings and other planets (Pro version)"
URL="https://www.google.com/earth/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case "$(epm print info -p)" in
  rpm)
      PKGURL="https://dl.google.com/dl/earth/client/current/google-earth-pro-stable-current.x86_64.rpm"
      ;;
  *)
      PKGURL="https://dl.google.com/dl/earth/client/current/google-earth-pro-stable-current.x86_64.deb"
      ;;
esac


install_pkgurl
