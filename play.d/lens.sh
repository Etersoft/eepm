#!/bin/sh

PKGNAME=kontena-lens
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Is the most powerful IDE for people who need to deal with Kubernetes clusters on a daily basis. Ensure your clusters are properly setup and configured"
URL="https://snapcraft.io/kontena-lens"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="$(snap_get_pkgurl https://snapcraft.io/kontena-lens)"

install_pkgurl
