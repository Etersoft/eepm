#!/bin/sh

PKGNAME=teams
DESCRIPTION="Microsoft Teams for Linux from the official site"

. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# rpm and deb contains the same binaries
#https://packages.microsoft.com/yumrepos/ms-teams/teams-1.3.00.25560-1.x86_64.rpm

# epm uses eget to download * names
epm install "https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/$(epm print constructname teams "*" amd64 deb)"
chmod 4755 /opt/teams/chrome-sandbox
