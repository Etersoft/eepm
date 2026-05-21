#!/bin/sh

PKGNAME=forticlient
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="FortiClient VPN-only from the official site"
URL="https://www.fortinet.com/support/product-downloads"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Fortinet page has only shortlinks, and filestore directory listing is closed.
VERSION="7.4.3.5411"

case "$(epm print info -p)" in
    rpm)
        PKGURL="https://filestore.fortinet.com/forticlient/downloads/forticlient_vpn_${VERSION}_x86_64.rpm"
        ;;
    *)
        PKGURL="https://filestore.fortinet.com/forticlient/downloads/forticlient_vpn_${VERSION}_amd64.deb"
        ;;
esac

install_pkgurl
