#!/bin/sh

PKGNAME=schildichat-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Matrix client / Element Web / Desktop fork'
URL="https://schildi.chat/"

. $(dirname $0)/common.sh

# Version support is temporarily disabled due to the use of unusual version suffix
warn_version_is_not_supported

pkgtype="$(epm print info -p)"

# upstream uses dash as version separator (1.11.36-sc.3); app-versions stores it as 1.11.36_sc.3
URLVERSION="$(echo "$VERSION" | tr '_' '-')"

case $pkgtype in
    rpm)
        mask="${PKGNAME}-${URLVERSION}.x86_64.rpm"
        ;;
    deb|*)
        mask="${PKGNAME}_${URLVERSION}_amd64.deb"
        ;;
esac

PKGURL=""
if [ "$VERSION" != "*" ] ; then
    PKGURL="https://github.com/SchildiChat/schildichat-desktop/releases/download/v${URLVERSION}/${mask}"
    eget --check-url "$PKGURL" >/dev/null 2>&1 || PKGURL=""
fi
[ -n "$PKGURL" ] || PKGURL=$(get_github_url "https://github.com/SchildiChat/schildichat-desktop/" "$mask")

install_pkgurl

