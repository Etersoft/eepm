#!/bin/sh

PKGNAME=amnezia-vpn
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="AmneziaVPN client for self-hosted VPN (from the official site)"
URL="https://github.com/amnezia-vpn/amnezia-client"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "AmneziaVPN_${VERSION}_linux_x64.run")
else
    PKGURL="https://github.com/amnezia-vpn/amnezia-client/releases/download/$VERSION/AmneziaVPN_${VERSION}_linux_x64.run"
fi

install_pack_pkgurl || exit

echo
echo "Enable and start the AmneziaVPN service:
    # serv AmneziaVPN on
"
