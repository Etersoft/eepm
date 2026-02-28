#!/bin/sh

PKGNAME=Blockbench
SUPPORTEDARCHES="x86_64"
DESCRIPTION='A low-poly 3D model editor'
URL="https://blockbench.net"

. $(dirname $0)/common.sh


pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        ext="rpm"
        ;;
    *)
        ext="deb"
        ;;
esac

PKGURL=$(get_github_url "https://github.com/JannisX11/blockbench" "Blockbench_${VERSION}.${ext}")

install_pkgurl
