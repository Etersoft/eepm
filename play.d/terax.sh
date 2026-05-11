#!/bin/sh

PKGNAME=terax
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A lightweight AI terminal with a built-in editor, AI agents, and live web preview"
URL="https://github.com/crynta/terax-ai"

. $(dirname $0)/common.sh

case $(epm print info -p) in
    rpm)
        mask="Terax-${VERSION}.x86_64.rpm"
        ;;
    *)
        mask="Terax_${VERSION}_amd64.deb"
        ;;
esac


Terax-0.6.1-1.x86_64.rpm

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/crynta/terax-ai" "$mask")
else
    PKGURL="https://github.com/crynta/terax-ai/releases/download/v${VERSION}/$mask"
fi

install_pkgurl
