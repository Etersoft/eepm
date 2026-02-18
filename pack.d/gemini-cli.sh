#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

mkdir -p usr/bin
mkdir -p etc/gemini-cli

mv -v $TAR usr/bin/gemini

chmod 755 usr/bin/gemini

PKGNAME=$PRODUCT-$VERSION

cat <<EOF > etc/gemini-cli/system-defaults.json
{
  "general": {
    "enableAutoUpdate": false,
    "enableAutoUpdateNotification": false
  }
}
EOF

erc pack $PKGNAME.tar usr etc || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: Apache-2.0
url: https://github.com/google-gemini/gemini-cli
summary:  The open source coding agent.
description: An open-source AI agent that brings the power of Gemini directly into your terminal
EOF

return_tar $PKGNAME.tar
