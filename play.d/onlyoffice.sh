#!/bin/sh

PKGNAME=onlyoffice-desktopeditors
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="ONLYOFFICE for Linux from the official site"

. $(dirname $0)/common.sh

arch=$(epm print info --distro-arch)
case "$(epm print info -p)" in
  rpm)
      file=onlyoffice-desktopeditors.x86_64.rpm
      pkgtype=rpm
      ;;
  *)
      file=onlyoffice-desktopeditors_amd64.deb
      pkgtype=deb
      ;;
esac

case "$(epm print info -s)" in
  alt)
      arch=amd64
      file=onlyoffice-desktopeditors_amd64.deb
      pkgtype=deb
      ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://github.com/ONLYOFFICE/DesktopEditors/releases $file)"
else
    PKGURL="https://github.com/ONLYOFFICE/DesktopEditors/releases/download/v$VERSION/$file"
fi

#https://github.com/ONLYOFFICE/DesktopEditors/releases/download/v7.4.0/onlyoffice-desktopeditors.x86_64.rpm
#https://github.com/ONLYOFFICE/DesktopEditors/releases/download/v7.4.0/onlyoffice-desktopeditors_amd64.deb
#PKGURL="https://download.onlyoffice.com/install/desktop/editors/linux/"
#PKGURL="$(eget --list --latest https://github.com/ONLYOFFICE/DesktopEditors/releases $(epm print constructname $PKGNAME "$VERSION" $arch $pkgtype))"

epm install "$PKGURL"
