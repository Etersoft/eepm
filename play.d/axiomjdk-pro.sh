#!/bin/sh

BASEPKGNAME=axiomjdk-pro
PRODUCTALT="25 21 17 11 8 27"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Axiom JDK Pro Full (Russian OpenJDK build with JavaFX) from the official site'
URL="https://axiomjdk.ru/downloads/axiom-jdk"
TIPS="Run 'epm play axiomjdk-pro=<25|21|17|11|8|27>' to install the selected Java version (25 LTS by default). Production use of Axiom JDK Pro requires a commercial subscription. Set JAVA_HOME=/usr/lib/jvm/axiomjdk-java<version>-pro-full.x86_64 if needed."

. $(dirname $0)/common.sh

# convert package version to the release tag: 25.0.5.1.0.5 -> 25.0.5.1+5, 1.8.0.514.0.5 -> 8u514+5
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

if [ "$VERSION" = "*" ] ; then
    # the page contains embedded JSON with all packages
    PKGURL="$(fetch_url "$URL" | sed -e 's|\\"|"|g' -e 's|},{|}\n{|g' | \
        grep '"bundleType":"jdk-full"' | grep '"packageType":"rpm"' | grep '"architecture":"x86"' | \
        grep "\"featureVersion\":$BRANCH," | grep '"latestInFeatureVersion":true' | \
        grep -o '"downloadUrl":"[^"]*"' | head -n1 | cut -d'"' -f4)"
else
    # https://download.axiomjdk.ru/axiomjdk-pro/25.0.5.1+5/axiomjdk-jdk-pro25.0.5.1+5-linux-amd64-full.rpm
    PKGURL="https://download.axiomjdk.ru/axiomjdk-pro/$VERSION/axiomjdk-jdk-pro$VERSION-linux-amd64-full.rpm"
fi
[ -n "$PKGURL" ] || fatal "Can't get package URL"

export EPM_REPACK_SCRIPT=axiomjdk-pro

install_pkgurl
