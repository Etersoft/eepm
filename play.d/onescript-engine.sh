#!/bin/sh

PKGNAME=onescript-engine
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="OneScript Engine from the official site"
TIPS="Run epm play onescript-engine=<version> to install specific version (e.g. 2.0.0 or 1.9.3)."
URL="https://oscript.io/downloads"

. $(dirname $0)/common.sh

webversion=$(echo "$VERSION" | sed 's|\.|_|g')

# scd-lin (self-contained Linux) appeared in 2.0.0
# for older versions use deb/rpm from oscript.io downloads
if [ "$VERSION" = "*" ] || [ "$(epm print compare "$VERSION" 2.0.0)" != "-1" ] ; then
    [ "$VERSION" = "*" ] && webversion=latest
    PKGURL="$URL/$webversion/scd-lin/x64"
    install_pack_pkgurl
else
    pkgtype=$(epm print info -p)
    case $pkgtype in
        rpm)
            PKGURL="$URL/$webversion/rpm/x64"
            ;;
        *)
            PKGURL="$URL/$webversion/deb/x64"
            ;;
    esac
    install_pkgurl
fi
