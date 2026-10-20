#!/bin/sh

PKGNAME=lumine-capture
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Fast, lightweight Wayland screenshot tool'
URL="https://github.com/Netflate/LumineCapture"

. $(dirname $0)/common.sh

case "$(epm print info -p)" in
    rpm)
        arch=$(epm print info -a)
        PKGURL=$(get_github_url "$URL" "${PKGNAME}-${VERSION}-*.${arch}.rpm")
        ;;
    *)
        arch=$(epm print info --debian-arch)
        PKGURL=$(get_github_url "$URL" "${PKGNAME}_${VERSION}-*_${arch}.deb")
        ;;
esac

install_pkgurl
