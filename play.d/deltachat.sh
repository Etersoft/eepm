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

arch=$(epm print info --distro-arch)

PKGURL=$(eget --list --latest https://delta.chat/ru/download "deltachat-desktop*$arch.$pkgtype")

install_pkgurl
