#!/bin/sh

PKGNAME=rustdesk-libsciter-gtk
SUPPORTEDARCHES="x86_64 aarch64"
DESCRIPTION='Embeddable HTML/CSS/JavaScript engine for modern UI development (only for RustDesk from Sisyphus)'
URL="https://github.com/c-smile/sciter-sdk"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case "$(epm print info -a)" in
    x86_64)
        arch="x64" ;;
    aarch64)
        arch="arm64" ;;
esac

VERSION="4.4.8.23"
PKGURL="https://raw.githubusercontent.com/c-smile/sciter-sdk/master/bin.lnx/$arch/libsciter-gtk.so"

install_pack_pkgurl "$VERSION"
