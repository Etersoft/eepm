#!/bin/sh

PKGNAME=smartgit
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="SmartGit - Git GUI client with GitHub, GitLab, Bitbucket integration"
URL="https://www.syntevo.com/smartgit/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    URLVERSION=$(eget -q -O- https://www.smartgit.dev/download/ | grep -oP 'smartgit-\K[0-9_]+(?=-linux-amd64\.tar\.gz)' | head -1)
    [ -n "$URLVERSION" ] || fatal "Can't get version"
    VERSION="$(echo "$URLVERSION" | tr '_' '.')"
else
    URLVERSION="$(echo "$VERSION" | tr '.' '_')"
fi

PKGURL="https://download.smartgit.dev/smartgit/smartgit-$URLVERSION-linux-amd64.tar.gz"

install_pack_pkgurl
