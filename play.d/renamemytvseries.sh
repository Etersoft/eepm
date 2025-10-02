#!/bin/sh

PKGNAME=RenameMyTVSeries
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Rename your TV-Series using TheTVDB (GTK2 version)"
URL="https://www.tweaking4all.com/home-theatre/rename-my-tv-series-v2/"

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://www.tweaking4all.com/downloads/video/ "RenameMyTVSeries-${VERSION}-GTK-Linux-x64-static-ffmpeg.tar.xz")

install_pack_pkgurl
