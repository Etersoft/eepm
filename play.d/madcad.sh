#!/bin/sh

PKGNAME=uimadcad
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='uimadcad is a GUI (Graphical User Interface) meant to ease the use of pymadcad'
URL="https://madcad.netlify.app/uimadcad"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case $(epm print info -p) in
    rpm)
        mask="uimadcad-*.x86_64.rpm"
        ;;
    deb)
        mask="uimadcad_*_amd64.deb"
        ;;
    *)
        mask="uimadcad*$arch.tar.gz"
        ;;
esac

if [ $(epm print info -e) = 'ALTLinux/Sisyphus' ]; then
    epm install uimadcad && exit
fi 

PKGURL=$(eget --list --latest "https://madcad.netlify.app/uimadcad" "$mask")

if echo "$mask" | grep -qE 'rpm|deb'; then
    install_pkgurl || exit
else
    install_pack_pkgurl || exit
fi

if [ ! $(epm print info -e) = 'ALTLinux/Sisyphus' ]; then
    echo "Note: You need also to install pymadcad from pip:
# pip3 install pymadcad
"
fi
