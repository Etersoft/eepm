#!/bin/sh

PKGNAME=webex
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='AI-driven collaboration and customer experience that works for you'
URL="https://www.webex.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://binaries.webex.com/WebexDesktop-Ubuntu-Official-Package/Webex.deb"

install_pkgurl

