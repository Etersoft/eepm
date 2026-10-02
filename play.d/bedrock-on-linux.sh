#!/bin/sh

PKGNAME=bedrock-on-linux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='BedrockOnLinux - Minecraft Bedrock for Windows on Linux'
URL="https://github.com/Wyze3306/BedrockOnLinux"

. $(dirname $0)/common.sh

case "$(epm print info -p)" in
    rpm) file="$PKGNAME-$VERSION-1.x86_64.rpm" ;;
    *) file="${PKGNAME}_${VERSION}_amd64.deb" ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "$file")
else
    PKGURL="$URL/releases/download/v$VERSION/$file"
fi

install_pkgurl
