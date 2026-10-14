#!/bin/sh

PKGNAME=cisco-secure-client-vpn
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Cisco Secure Client (AnyConnect): VPN client"
URL="https://www.cisco.com/c/en/us/support/security/secure-client-5/model.html"

. "$(dirname "$0")/common.sh"

# Cisco requires authentication; Elisa publishes the vendor predeploy packages
# for its VPN customers.
case "$VERSION" in
    '*'|0)
        PKGURL="$(eget -O- https://yrityksille.elisa.fi/ohje/Elisa-VPN-ohjeet-ja-ohjelmistojen-lataus | grep -oE 'https://static\.elisa\.com/[^"<>[:space:]]*/cisco-secure-client-linux64-[0-9.]+-predeploy-deb-k9\.tgz' | sort -V | tail -n1)"
        ;;
    5.1.19.1862)
        PKGURL="https://static.elisa.com/v2/image/2tqybbhjs47b/6olslM74wAVrKnXAbs8tJP/cisco-secure-client-linux64-$VERSION-predeploy-deb-k9.tgz"
        ;;
    *) fatal "No public download is known for Cisco Secure Client version $VERSION" ;;
esac

install_pack_pkgurl --repack || exit
info "Start the VPN agent with 'serv vpnagentd start', then run cisco-secure-client."
