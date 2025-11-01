#!/bin/sh

PKGNAME=minecraft-launcher
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Minecraft launcher from the official site"
URL="https://www.minecraft.net/en-us/download"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# try install libcurl4-openssl if it is missed in the repo
epm install 399021

# https://www.minecraft.net/en-us/download
PKGURL="https://launcher.mojang.com/download/Minecraft.deb"

install_pkgurl
