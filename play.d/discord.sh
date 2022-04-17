#!/bin/sh

PKGNAME=discord
DESCRIPTION="Discord from the official site"

. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# curl can't get filename: https://github.com/curl/curl/issues/8461
epm assure wget
epm install "https://discord.com/api/download?platform=linux&format=deb"

