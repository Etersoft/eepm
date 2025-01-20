#!/bin/sh

PKGNAME=deltachat-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Delta Chat is a decentralized and secure messenger app"
URL="https://delta.chat/ru/download"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case "$(epm print info -p)" in
    rpm)
        pkgtype=rpm ;;
    deb|*)
        pkgtype=deb ;;
esac

if [ $pkgtype = 'deb' ]; then
    case $(epm print info -a) in
        x86_64)
            arch=amd64 ;;
        aarch64)
            arch=arm64 ;;
        *)
            fatal "Unsupported arch $arch for $(epm print info -d)"
    esac
else
    arch=$(epm print info -a)
fi

PKGURL=$(eget --list --latest https://delta.chat/ru/download "deltachat-desktop*$arch.$pkgtype")

install_pkgurl
