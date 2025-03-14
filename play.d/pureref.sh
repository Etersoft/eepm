#!/bin/sh

PKGNAME=PureRef
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Reference Image Viewer"
URL="https://www.pureref.com/index.php"

. $(dirname $0)/common.sh

warn_version_is_not_supported

key=$(eget -A -O- https://www.pureref.com/download.php | awk '/setupPaymentSystem/,/);/' | grep -zoP '\s+"\K[A-z0-9%]+?",' | sed 's/...$//')
VERSION=$(eget -O- "https://www.pureref.com/changelog.php" | grep -o -m 1 "Version [0-9].[0-9].[0-9]" | awk '{print $2}'| head -n 1)

PKGURL="https://www.pureref.com/files/build.php?build=LINUX64.deb&version=${VERSION}&downloadKey=$key"
export EGET_BACKEND=curl
install_pkgurl

