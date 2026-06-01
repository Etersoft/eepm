#!/bin/sh

PKGNAME=minimax-agent
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="MiniMax Agent (unofficial native Linux client)"
URL="https://github.com/unn-Known1/minimax-agent-linux"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(get_github_url https://github.com/unn-Known1/minimax-agent-linux "minimax-agent_*_amd64.deb")

install_pkgurl
