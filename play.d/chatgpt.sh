#!/bin/sh

PKGNAME=chatgpt
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Official OpenAI ChatGPT desktop app'
URL="https://learn.chatgpt.com/docs/linux/linux-app"

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
    pkg.tar.zst)
        BASEURL="https://persistent.oaistatic.com/codex-app-prod/linux/arch/$arch"
        filename="$(eget -O- "$BASEURL/openai-chatgpt.db" | tar -xzO --wildcards 'chatgpt-bin-*/desc' | sed -n '/^%FILENAME%$/{n;p;}')"
        case "$filename" in
            chatgpt-bin-*-"$arch".pkg.tar.zst) ;;
            *) fatal "Can't get ChatGPT $arch package filename" ;;
        esac
        PKGURL="$BASEURL/$filename"
        ;;
    *)
        fatal "$pkgtype package type is not supported"
        ;;
esac

install_pkgurl
