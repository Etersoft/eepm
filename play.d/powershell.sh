#!/bin/sh

PKGNAME=powershell
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Microsoft PowerShell from the official site"
URL="https://github.com/PowerShell/PowerShell"

. $(dirname $0)/common.sh

version=$(epm print info --base-version)

# Strict supported list
case $(epm print info -e) in
    Ubuntu/*)
        if [ "$VERSION" = "*" ] ; then
            PKGURL=$(eget --list --latest "https://packages.microsoft.com/ubuntu/$version/prod/pool/main/p/powershell/" "powershell_[0-9]*.deb_amd64.deb")
        else
            PKGURL="https://packages.microsoft.com/ubuntu/$version/prod/pool/main/p/powershell/powershell_${VERSION}-${RELEASE}.deb_amd64.deb"
        fi
        ;;
    *)
        if [ "$VERSION" = "*" ] ; then
            PKGURL=$(get_github_url "PowerShell/PowerShell" "powershell-*-1.rh.x86_64.rpm")
        else
            PKGURL="https://github.com/PowerShell/PowerShell/releases/download/v${VERSION}/powershell-${VERSION}-${RELEASE}.rh.x86_64.rpm"
        fi
        ;;
esac

install_pkgurl
