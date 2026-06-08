#!/bin/sh

PKGNAME=rustdesk
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="RustDesk — Display and control your PC and Android devices"
URL="https://github.com/rustdesk/rustdesk/"

. $(dirname $0)/common.sh

arch=$(epm print info -a)
pkgtype=deb

# get the latest stable tag via the API. eget --latest/--second-latest matched
# assets, but the nightly prerelease also ships rustdesk-<ver>-<arch>.deb files
# (1.4.7 and 1.4.6), so it wrongly picked the nightly 1.4.6 deb.
[ "$VERSION" = "*" ] && VERSION="$(get_github_tag "$URL")"

if [ "$VERSION" = "1.1.9" ] ; then
    #rustdesk-1.1.9.deb
    asset="$PKGNAME-$VERSION.$pkgtype"
else
    asset="$PKGNAME-$VERSION-$arch.$pkgtype"
fi

PKGURL="$(get_github_url "$URL" "$asset")"

install_pkgurl || exit

cat <<EOF

Note: run
# serv rustdesk on
to enable needed rustdesk system service (daemon)
EOF
