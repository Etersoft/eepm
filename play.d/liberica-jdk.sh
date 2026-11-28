#!/bin/sh

BASEPKGNAME=liberica-jdk
PRODUCTALT="25 21 17 11 8 27"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='BellSoft Liberica JDK Full (OpenJDK build with JavaFX) from the official site'
URL="https://github.com/bell-sw/Liberica/"
TIPS="Run 'epm play liberica-jdk=<25|21|17|11|8|27>' to install the selected Java version (25 LTS by default). Set JAVA_HOME=/usr/lib/jvm/liberica-jdk-<version> if needed."

. $(dirname $0)/common.sh

# convert package version to the release tag: 11.0.20.0.0.8 -> 11.0.20+8, 1.8.0.514.0.5 -> 8u514+5
case "$VERSION" in
    "*"|*+*)
        ;;
    1.8.0.*)
        VERSION="$(echo "$VERSION" | sed -E 's|^1\.8\.0\.([0-9]+)\.[0-9]+\.([0-9]+)$|8u\1+\2|')"
        ;;
    *)
        VERSION="$(echo "$VERSION" | sed -E -e 's|\.([0-9]+)$|+\1|' -e 's|(\.0)+\+|+|')"
        ;;
esac

# bellsoft-jdk25.0.5.1+5-linux-amd64-full.rpm, bellsoft-jdk8u514+5-linux-amd64-full.rpm
if [ "$VERSION" = "*" ] ; then
    [ "$BRANCH" = "8" ] && mask="bellsoft-jdk8u*-linux-amd64-full.rpm" || mask="bellsoft-jdk$BRANCH.*-linux-amd64-full.rpm"
    PKGURL="$(get_github_url "$URL" "$mask")"
else
    tag="$(echo "$VERSION" | sed -e 's|+|%2B|')"
    PKGURL="https://github.com/bell-sw/Liberica/releases/download/$tag/bellsoft-jdk$tag-linux-amd64-full.rpm"
fi
[ -n "$PKGURL" ] || fatal "Can't get package URL"

export EPM_REPACK_SCRIPT=liberica-jdk

install_pkgurl
