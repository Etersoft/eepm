#!/bin/sh

PKGNAME=postman
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Postman is an API platform for building and using APIs'
URL="https://www.postman.com"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case "$(epm print info -a)" in
    x86_64)
        arch="64" ;;
    aarch64)
        arch="arm64" ;;
esac

PKGURL="https://dl.pstmn.io/download/latest/linux_$arch"

install_pack_pkgurl
