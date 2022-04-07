#!/bin/sh

PKGNAME=discord
DESCRIPTION="Discord from the official site"

. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

epm install "https://discord.com/api/download?platform=linux&format=deb"

