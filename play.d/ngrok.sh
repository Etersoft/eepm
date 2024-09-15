#!/bin/sh

PKGNAME=ngrok
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="ngrok is the programmable network edge that adds connectivity, security, and observability to your apps with no code changes."
URL="https://ngrok.com/"

. $(dirname $0)/common.sh

PKGURL="$(snap_get_pkgurl https://snapcraft.io/ngrok)"

install_pkgurl
