#!/bin/sh

PKGNAME=librewolf
SUPPORTEDARCHES="x86_64"
DESCRIPTION="LibreWolf - a custom version of Firefox, focused on privacy, security and freedom"

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKG="https://rpm.librewolf.net/pool/librewolf*.rpm"
        ;;
    deb)
        PKG="https://deb.librewolf.net/pool/focal/main/libr/librewolf/librewolf_*all.deb"
        ;;
    *)
        fatal "Package target $pkgtype is not supported yet"
        ;;
esac

case "$(epm print info -s)" in
  alt)
      # uses old glibc needed for ALT p10
      PKG="https://deb.librewolf.net/pool/focal/main/libr/librewolf/librewolf_*all.deb"
      epm install --repack $PKG
      exit
      ;;
esac

epm install "$PKG"
