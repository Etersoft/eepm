#!/bin/sh

PKGNAME=teams
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Microsoft Teams for Linux from the official site"

. $(dirname $0)/common.sh


# rpm and deb contains the same binaries
#https://packages.microsoft.com/yumrepos/ms-teams/teams-1.3.00.25560-1.x86_64.rpm

# epm uses eget to download * names
epm install "https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/$(epm print constructname teams "*" amd64 deb)"
