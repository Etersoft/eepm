#!/bin/sh

PKGNAME=chat-gpt
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Unofficial ChatGPT Desktop Application from the official site'
URL="https://github.com/lencx/ChatGPT"

. $(dirname $0)/common.sh

is_openssl_enough 3 || fatal "There is no needed OpenSSL 3 in the system."

# https://github.com/lencx/ChatGPT/releases/download/v1.0.0/ChatGPT_1.0.0_linux_x86_64.deb
PKGURL=$(epm tool eget --list --latest https://github.com/lencx/ChatGPT/releases/ "ChatGPT_${VERSION}_linux_x86_64.deb") || fatal "Can't get package URL"

epm install "$PKGURL"
