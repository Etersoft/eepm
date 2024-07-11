#!/bin/sh

PKGNAME=snap4arduino
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="Snap4Arduino binds Snap! and Arduino together"
URL="https://github.com/bromagosa/Snap4Arduino"

. $(dirname $0)/common.sh

arch=$(epm print info --distro-arch)
case $arch in
    x86_64|amd64)
        arch=64 ;;
    i586)
        arch=32 ;;
    *)
        fatal "Unsupported arch $arch for $(epm print info -d)"
esac

PKGURL=$(get_github_version "https://github.com/bromagosa/Snap4Arduino/" "Snap4Arduino_desktop-gnu-$arch_.*.tar.gz") #

install_pack_pkgurl
