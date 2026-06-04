#!/bin/sh

PKGNAME=glds
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Guardant License Server from the official site"
URL="https://www.guardant.ru/support/users/server/"

. $(dirname $0)/common.sh

base_url="https://ftp.guardant.ru/LM/Linux"

[ "$VERSION" = "*" ] && VERSION="$(basename "$(eget --list --latest "$base_url/" '*/')")"
[ -n "$VERSION" ] || fatal "Can't get version."

shortarch=x64

pkgtype="$(epm print info -p)"

# there are incorrect version in the package name
case "$pkgtype" in
    rpm)
        file="glds-*.x86_64.rpm"
        ;;
    deb)
        file="glds-*_amd64.deb"
        ;;
    *)
        file="glds-*_amd64.deb"
        ;;
esac

PKGURL="$(eget --list --latest "$base_url/$VERSION/" "$file")"
[ -n "$PKGURL" ] || PKGURL="$(eget --list --latest "$base_url/$VERSION/$shortarch/" "$file")"

install_pack_pkgurl "$VERSION" || exit

cat <<EOF

Note: run
# serv glds on
to start Guardant License Server permanently
EOF
