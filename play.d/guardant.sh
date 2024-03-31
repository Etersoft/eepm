#!/bin/sh

PKGNAME=glds
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Guardant License Server from the official site"
URL="https://www.guardant.ru/support/users/download/1223/"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION="$(basename $(eget --list --latest https://download.guardant.ru/LM/Linux/ '*/'))"
[ -n "$VERSION" ] || fatal "Can't get version."

shortarch=x64

pkgtype="$(epm print info -p)"

# there are incorrect version in the package name
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

PKGURL=$(eget --list --latest https://download.guardant.ru/LM/Linux/$VERSION/$shortarch/ "$file")

install_pack_pkgurl "$VERSION"

cat <<EOF

Note: run
# serv glds on
to start Guardant License Server permanently
EOF
