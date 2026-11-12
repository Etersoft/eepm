#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(basename "$URL" | sed -n 's/^agent-desktop-\(.*\)\.tgz$/\1/p')"
[ -n "$VERSION" ] || fatal "Can't get package version"

erc --here unpack "$TAR" || fatal

case "$(epm print info -a)" in
    x86_64) arch=x64 ;;
    aarch64) arch=arm64 ;;
    *) fatal "Unsupported architecture" ;;
esac

# The clipboard helper must live next to the main executable.
install -Dm755 "package/bin/agent-desktop-linux-$arch" usr/bin/agent-desktop || fatal
install -Dm755 "package/bin/agent-desktop-linux-clipboard-owner-linux-$arch" usr/bin/agent-desktop-linux-clipboard-owner || fatal

PKGNAME=$PRODUCT-$VERSION
erc pack "$PKGNAME.tar" usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: Apache-2.0
url: https://github.com/vercel-labs/agent-desktop
summary: Desktop automation CLI for AI agents
description: Desktop automation CLI for AI agents.
EOF

return_tar "$PKGNAME.tar"
