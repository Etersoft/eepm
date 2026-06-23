#!/bin/sh

PKGNAME=opentabletdriver
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Open source tablet driver with Linux packages from the official GitHub releases'
URL="https://github.com/OpenTabletDriver/OpenTabletDriver"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

case "$pkgtype" in
    rpm)
        mask="opentabletdriver-${VERSION}-1.x86_64.rpm" ;;
    *)
        # TODO fix debian
        mask="opentabletdriver_${VERSION}-1_x64.deb" ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "https://github.com/OpenTabletDriver/OpenTabletDriver" "$mask")"
else
    PKGURL="https://github.com/OpenTabletDriver/OpenTabletDriver/releases/download/v$VERSION/$mask"
fi

[ -n "$PKGURL" ] || fatal "Can't find $PKGNAME package in GitHub releases."

install_pkgurl || exit

echo "Note: run
$ serv --user opentabletdriver on
to enable the OpenTabletDriver user service
"
