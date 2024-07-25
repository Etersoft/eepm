#!/bin/sh

PKGNAME=madcad
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION='uimadcad is a GUI (Graphical User Interface) meant to ease the use of pymadcad'
URL="https://madcad.netlify.app/uimadcad"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(eget --list --latest "https://madcad.netlify.app/uimadcad" "uimadcad*$arch.tar.gz")

install_pack_pkgurl

if [ ! $(epm print info -e) = 'ALTLinux/Sisyphus' ]; then
    echo "Note: You need to install pymadcad from pip:
$ pip3 install pymadcad
"
fi 