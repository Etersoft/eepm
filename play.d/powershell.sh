#!/bin/sh

PKGNAME=powershell
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Microsoft PowerShell from the official site"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION="[0-9]*" || VERSION="$VERSION-1"

reponame=$(epm print info --repo-name)
vendor=$(epm print info -s)
version=$(epm print info --base-version)

# Strict supported list
case $(epm print info -e) in
    Ubuntu/*)
        BASEURL="https://packages.microsoft.com/ubuntu/$version/prod/pool/main/p/powershell/"
        file="powershell_$VERSION.deb_amd64.deb"
        ;;
    *)
        PKGURL="https://github.com/PowerShell/PowerShell/releases"
        file="powershell-$VERSION.rh.x86_64.rpm"
        ;;
esac

PKGURL=$(epm tool eget --list --latest $BASEURL $file) || fatal "Can't get package URL"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm install $repack "$PKGURL" || exit

