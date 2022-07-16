#!/bin/sh

PKGNAME=discord
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Discord from the official site"

. $(dirname $0)/common.sh


epm assure wget || fatal "Can't install wget, but curl can't get filename: https://github.com/curl/curl/issues/8461"
epm install "https://discord.com/api/download?platform=linux&format=deb"

