#!/bin/sh

PKGNAME=bellsoft-java11-full
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='BellSoft Liberica JDK 11 Full (see liberica-jdk for other Java versions)'
URL="https://github.com/bell-sw/Liberica/"

. $(dirname $0)/common.sh

# convert package version to the release tag: 11.0.20.0.0.8 -> 11.0.20+8
case "$VERSION" in
    "*"|*+*)
        ;;
    *)
        VERSION="$(echo "$VERSION" | sed -E -e 's|\.([0-9]+)$|+\1|' -e 's|(\.0)+\+|+|')"
        ;;
esac

# bellsoft-jdk11.0.33.1+5-linux-amd64-full.rpm
if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "bellsoft-jdk11.*-linux-amd64-full.rpm")"
else
    tag="$(echo "$VERSION" | sed -e 's|+|%2B|')"
    PKGURL="https://github.com/bell-sw/Liberica/releases/download/$tag/bellsoft-jdk$tag-linux-amd64-full.rpm"
fi
[ -n "$PKGURL" ] || fatal "Can't get package URL"

install_pkgurl
