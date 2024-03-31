#!/bin/sh

PKGNAME=wing-personal10
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Wing Python IDE Personal from the official site"
URL="https://wingware.com/"

. $(dirname $0)/common.sh

# https://wingware.com/pub/wing-personal/10.0.2.0/wing-personal10_10.0.2-0_amd64.deb
# https://wingware.com/pub/wing-personal/10.0.2.0/wing-personal10-10.0.2-0.x86_64.rpm

BASEURL="https://wingware.com/pub/wing-personal"

if [ "$VERSION" = "*" ] ; then
    DIRVERSION="$(eget --list --latest "$BASEURL/10.*" | xargs basename)"
    VERSION="$(echo $DIRVERSION | sed -e 's|\.[0-9]$||')"
else
    # TODO: get full version from site
    DIRVERSION=$VERSION.0
fi

arch=$(epm print info --distro-arch)

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        mask="$PKGNAME-${VERSION}-*.$arch.rpm"
        ;;
    deb)
        mask="${PKGNAME}_${VERSION}-*_$arch.deb"
        ;;
esac

PKGURL="$(eget --list --latest $BASEURL/$DIRVERSION/ "$mask")" || fatal "Can't get package URL"
#PKGURL="https://wingware.com/pub/wing-personal/$VERSION/$mask"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm install $repack "$PKGURL"
