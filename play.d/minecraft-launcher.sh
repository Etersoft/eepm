#!/bin/sh

PKGNAME=minecraft-launcher
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Minecraft launcher from the official site"

. $(dirname $0)/common.sh

# https://www.minecraft.net/en-us/download
epm install "https://launcher.mojang.com/download/Minecraft.deb"

