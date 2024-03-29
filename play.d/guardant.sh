#!/bin/sh

PKGNAME=glds
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Guardant License Server from the official site"
URL="https://www.guardant.ru/support/users/download/1223/"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION="$(basename $(epm tool eget --list --latest https://download.guardant.ru/LM/Linux/ '*/'))"

shortarch=x64

pkgtype="$(epm print info -p)"

case "$pkgtype" in
    rpm)
        file="glds-*.x86_64.rpm"
        ;;
    deb)
        file="glds-*_x86_64.deb"
        ;;
    *)
        file="glds-*_x86_64.deb"
        ;;
esac

PKGURL=$(epm tool eget --list --latest https://download.guardant.ru/LM/Linux/$VERSION/$shortarch/ "$file") || fatal "Can't get package URL"

repack=''
[ "$pkgtype" = "rpm" ] && repack='--repack'

epm pack $PKGNAME $repack --install "$PKGURL" "$VERSION" || exit

cat <<EOF

Note: run
# serv glds on
to start Guardant License Server permanently
EOF
