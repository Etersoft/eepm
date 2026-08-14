#!/bin/sh

PKGNAME=happ
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Proxy utility with Xray core (VLESS, VMess, Trojan, Shadowsocks, Socks)"
URL="https://github.com/Happ-proxy/happ-desktop"

. $(dirname $0)/common.sh

is_openssl_enough 3 || fatal "OpenSSL 3 is required"

if [ "$VERSION" = "*" ]; then
    PKGURL=$(get_github_url "$URL" "Happ.linux.x64.rpm")
else
    PKGURL="$URL/releases/download/$VERSION/Happ.linux.x64.rpm"
fi

install_pkgurl || exit

cat <<EOF

Note: run
# serv on happd.service
to enable needed happ system service (daemon)

EOF
