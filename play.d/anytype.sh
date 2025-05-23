#!/bin/sh

PKGNAME=Anytype
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='The everything app for those who celebrate trust & autonomy'
URL="https://anytype.io/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="$(get_json_value https://publish-releases.anytype.io/api/v1/latestRelease '["LatestReleasesLinks","LINUX_APP_IMAGE","url"]')"

install_pkgurl

