#!/bin/sh

PKGNAME=signal-desktop
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Signal private messenger from the official site'
DOWNURL="https://updates.signal.org/desktop/apt/pool/main/s/signal-desktop"

. $(dirname $0)/common.sh

URL=$(epm tool eget --list --latest http://mirror.cs.uchicago.edu/signal/pool/main/s/signal-desktop/ '${PKGNAME}_*_amd64.deb')
URL=$(echo "$URL" | sed -e "s|\(.*/\)|$DOWNURL/|")
epm install "$URL"
