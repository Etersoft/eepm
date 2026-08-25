#!/bin/sh

PKGNAME=deltachat-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Delta Chat is a decentralized and secure messenger app"
URL="https://github.com/deltachat/deltachat-desktop"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case "$(epm print info -p)" in
    rpm)
        pkgtype=rpm
        arch=$(epm print info -a)
        ;;
    *)
        pkgtype=deb
        arch=$(epm print info --debian-arch)
        ;;
esac

PKGURL=$(get_github_url "$URL" "deltachat-desktop*$arch.$pkgtype")

install_pkgurl
