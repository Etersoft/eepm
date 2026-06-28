#!/bin/sh

PKGNAME=trae
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Trae - AI-powered IDE'
URL="https://www.trae.ai/"

. $(dirname $0)/common.sh

# the vendor builds the download URL at runtime and has no public "latest" link,
# so pin a known stable version as the default (a specific version can be requested)
[ "$VERSION" = "*" ] && VERSION="2.3.44884"

PKGURL="https://lf-cdn.trae.ai/obj/trae-ai-us/pkg/app/releases/stable/$VERSION/linux/Trae-linux-x64.deb"

install_pkgurl
