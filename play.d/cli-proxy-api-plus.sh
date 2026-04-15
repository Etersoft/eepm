#!/bin/sh
PKGNAME=cli-proxy-api-plus
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Proxy server providing OpenAI/Gemini/Claude compatible API interfaces"
URL="https://github.com/router-for-me/CLIProxyAPIPlus"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch=$(epm print info --debian-arch)

PKGURL=$(get_github_url https://github.com/router-for-me/CLIProxyAPIPlus "CLIProxyAPIPlus_${VERSION}_linux_$arch.tar.gz" )

install_pack_pkgurl
