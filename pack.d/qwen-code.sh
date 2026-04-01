#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

mkdir -p usr/bin
mkdir -p etc/qwen-code
mkdir -p opt/qwen-code

erc --here unpack $TAR || fatal

cp -a "package/." "opt/qwen-code/"

chmod 755 "opt/qwen-code/cli.js"

ln -s "/opt/qwen-code/cli.js" "usr/bin/qwen"

PKGNAME=$PRODUCT-$VERSION

cat <<EOF > etc/qwen-code/system-defaults.json
{
  "\$version": 3,
  "general": {
    "enableAutoUpdate": false
  }
}
EOF

erc pack $PKGNAME.tar usr opt etc || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: Apache-2.0
url: https://github.com/QwenLM/qwen-code
summary:  The open source coding agent.
description: Open-source AI agent based on Gemini CLI by QwenLM.
EOF

return_tar $PKGNAME.tar
