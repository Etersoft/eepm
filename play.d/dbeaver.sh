#!/bin/sh

PKGNAME=dbeaver-ce
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="DBeaver Community from the official site"
URL="https://dbeaver.io/"

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
[ "$pkgtype" = "rpm" ] && ext=rpm || ext=deb

if [ "$VERSION" = "*" ] ; then
    PKGURL="https://dbeaver.io/files/dbeaver-ce-latest-linux-x86_64.$ext"
else
    # DBeaver renamed its release assets over time (older 25.3.2-25.3.4: -stable.x86_64,
    # newer: -linux-x86_64). Resolve the real file from the GitHub release by trying the
    # current name, then the legacy one (dbeaver.io just redirects to GitHub).
    DBEAVER_GH="https://github.com/dbeaver/dbeaver"
    PKGURL="$(get_github_url "$DBEAVER_GH" "dbeaver-ce-$VERSION-linux-x86_64.$ext")"
    [ -n "$PKGURL" ] || PKGURL="$(get_github_url "$DBEAVER_GH" "dbeaver-ce-$VERSION-stable.x86_64.$ext")"
fi

install_pkgurl
