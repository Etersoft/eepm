#!/bin/sh

PKGNAME=powershell
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Microsoft PowerShell from the official site"
URL="https://github.com/PowerShell/PowerShell"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="[0-9]*"
elif [ -n "$RELEASE" ] ; then
    VERSION="${VERSION}-${RELEASE}"
fi

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
        BASEURL="https://github.com/PowerShell/PowerShell/releases"
        # RELEASE from app-versions already contains .rh suffix
        if echo "$VERSION" | grep -q "\.rh$" ; then
            file="powershell-$VERSION.x86_64.rpm"
        else
            file="powershell-$VERSION.rh.x86_64.rpm"
        fi
        ;;
esac

PKGURL=$(eget --list --latest $BASEURL "$file")

install_pkgurl
