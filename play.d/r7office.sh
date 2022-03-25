#!/bin/sh

PKGNAME=r7-office
DESCRIPTION="R7 Office for Linux from the official site"


. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

#arch=$($DISTRVENDOR --distro-arch)
arch=amd64
#pkgtype=$($DISTRVENDOR -p)
pkgtype=rpm

PKG="https://download.r7-office.ru/altlinux/r7-office.rpm"

epm install fonts-ttf-dejavu fonts-ttf-google-crosextra-carlito fonts-ttf-liberation glibc gst-libav gst-plugins-ugly1.0 libX11 libXScrnSaver libcairo libgcc1 libgtk+2 libgtkglext
epm install "$PKG"
