#!/bin/sh

PKGNAME=xnview
SUPPORTEDARCHES="x86_64"
DESCRIPTION="XnView MP: Image management from the official site"

. $(dirname $0)/common.sh

epm install https://download.xnview.com/XnViewMP-linux-x64.deb
