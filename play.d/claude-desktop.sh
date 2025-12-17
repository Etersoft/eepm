#!/bin/sh

PKGNAME=claude-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Claude Desktop (Wine based)"
URL="https://claude.com/download"

. $(dirname $0)/common.sh

if ! is_command wine ; then
    epm play wine || fatal
fi

warn_version_is_not_supported

#https://claude.ai/redirect/claudedotcom.v1.1029bab3-186e-4985-87e7-b2a711d887b4/api/desktop/win32/arm64/exe/latest/redirect
#https://claude.ai/redirect/claudedotcom.v1.1029bab3-186e-4985-87e7-b2a711d887b4/api/desktop/win32/x64/exe/latest/redirect

# https://claude.ai/api/desktop/win32/x64/exe/latest/redirect
# https://claude.ai/api/desktop/win32/arm64/exe/latest/redirect

VERSION="1.1029"
#PKGURL="https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe"
PKGURL="ipfs://Qme1jkcU95P5dCWTs5sMxsvUruBfaVQMrAhY2585AfsoVJ?filename=Claude-Setup-x64.exe"

install_pack_pkgurl $VERSION
