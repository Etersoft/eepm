#!/bin/sh

PKGNAME=nextcloud-talk
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Nextcloud Talk desktop client"
URL="https://github.com/nextcloud-releases/talk-desktop"
TIPS="Run 'epm play nextcloud-talk=<version>' to install the specified version of Nextcloud Talk."

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(get_github_url "$URL" "Nextcloud.Talk-linux-x64.zip")

epm --install pack $PKGNAME "$PKGURL"
