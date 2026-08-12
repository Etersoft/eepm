#!/bin/sh

PKGNAME=chatgpt
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Official OpenAI Codex desktop app'
URL="https://openai.com/codex/"

. $(dirname $0)/common.sh

is_openssl_enough 3 || fatal "There is no needed OpenSSL 3 in the system."

warn_version_is_not_supported

arch="$(epm print info -a)"
pkgtype="$(epm print info -p)"

case "$pkgtype" in
    deb)
        case "$arch" in
            x86_64) pkgarch=amd64 ;;
            aarch64) pkgarch=arm64 ;;
        esac
        PKGURL="https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_$pkgarch.deb"
        ;;
    rpm)
        PKGURL="https://persistent.oaistatic.com/codex-app-prod/linux/rpm/latest/chatgpt.$arch.rpm"
        ;;
    *)
        fatal "$pkgtype package type is not supported"
        ;;
esac

install_pkgurl
