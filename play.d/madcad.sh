#!/bin/sh

PKGNAME=uimadcad
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION='uimadcad is a GUI (Graphical User Interface) meant to ease the use of pymadcad'
URL="https://madcad.netlify.app/uimadcad"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case "$(epm print info -a)" in
    x86)
        arch="i686" ;;
    x86_64)
        arch="amd64" ;;
esac

PKGURL=$(eget --list --latest "https://madcad.netlify.app/uimadcad" "uimadcad*$arch.deb")

install_pkgurl
