#!/bin/sh

PKGNAME="grdcontrol"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Guardant Control Center Implements Guardant SLK functional"
URL="https://www.guardant.ru/support/users/control-center/"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION="$(basename $(eget --list --latest https://download.guardant.ru/Guardant_Control_Center/ '*/'))"
[ -n "$VERSION" ] || fatal "Can't get version."

pkgtype="$(epm print info -p)"

case "$pkgtype" in
    rpm)
        # all rpm have the same name pattern with "-0" before architecture
        file="grdcontrol-${VERSION}-0.x86_64.rpm"
        ;;
    deb)
        file="grdcontrol-${VERSION}_amd64.deb"
        ;;
    *)
        file="grdcontrol-${VERSION}_amd64.deb"
        ;;
esac

PKGURL="https://download.guardant.ru/Guardant_Control_Center/$VERSION/$file"

install_pkgurl || exit

cat <<EOF

Note: run
# serv grdcontrol on
to start Guardant Control Center permanently

Open http://localhost:3189 via a browser.
EOF
