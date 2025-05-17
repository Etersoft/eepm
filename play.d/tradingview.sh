#!/bin/sh

PKGNAME=tradingview
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="TradingView from the snapcraft"
URL="https://snapcraft.io/tradingview"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="$(snap_get_pkgurl $URL)"
install_pkgurl
