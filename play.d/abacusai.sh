#!/bin/sh

PKGNAME=abacusai-cli
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="AbacusAI's powerful CLI AI assistant with agentic browsing, listening, and coding capabilities"
URL="https://abacus.ai/help/abacusai-desktop/cli-installation"

. $(dirname $0)/common.sh


arch="$(epm print info -a)"

case "$arch" in
    x86_64)
        ARCH="x64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_json_value 'https://apps.abacus.ai/api/v0/_getCodellmCliVersion?channel=latest' '["result","version"]')"
    [ -n "$VERSION" ] || fatal "Can't get latest Abacus AI CLI version"
fi

suffix=''
# The baseline build also supports x86_64 CPUs without AVX2.
[ "$ARCH" = "x64" ] && suffix=-baseline
if ldd /bin/ls 2>&1 | grep -q musl ; then
    suffix=-musl
fi
PKGURL="https://static.abacus.ai/cli/releases/$VERSION/abacusai-linux-$ARCH$suffix.tar.gz"

install_pack_pkgurl "$VERSION"
