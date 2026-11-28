#!/bin/sh

PKGNAME=r7fe
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="R7 File-Express (R7-Disk desktop client) from the official site"
URL="https://support.r7-office.ru/download/file-express/"

. $(dirname $0)/common.sh

# https://download.r7-office.ru/fileexpress/altlinux/r7fe_amd64_2026.1.1.0331.rpm
# https://download.r7-office.ru/fileexpress/redos/r7fe_amd64_2026.1.1.0331.rpm
# https://download.r7-office.ru/fileexpress/astralinux/r7fe_amd64_2026.1.1.0331.deb
# https://download.r7-office.ru/fileexpress/debian/r7fe_amd64_2026.1.1.0331.deb
case $(epm print info -p) in
    rpm)
        dir="redos"
        ext="rpm"
        ;;
    *)
        dir="debian"
        ext="deb"
        ;;
esac

case $(epm print info -s) in
    alt)
        dir="altlinux"
        ext="rpm"
        ;;
    astra)
        dir="astralinux"
        ext="deb"
        ;;
esac

file="r7fe_amd64_${VERSION}.$ext"

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest "$URL" "$dir/$file")" || fatal "Can't get package URL"
else
    PKGURL="https://download.r7-office.ru/fileexpress/$dir/$file"
fi

install_pkgurl
