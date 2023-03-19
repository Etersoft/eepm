#!/bin/sh

DESCRIPTION=''

PKGNAME=chromium-codecs-ffmpeg-extra
SUPPORTEDARCHES="x86_64"
BASEPKGNAME=chromium

. $(dirname $0)/common.sh

# copied from /opt/vivaldi/update-ffmpeg
FFMPEG_VERSION_DEB=103.0.5060.134-0ubuntu0.18.04.1 # Internal FFMpeg version = 107578
FFMPEG_URL_DEB=https://launchpadlibrarian.net/613925272/chromium-codecs-ffmpeg-extra_${FFMPEG_VERSION_DEB}_amd64.deb

epm pack --install chromium-codecs-ffmpeg-extra $FFMPEG_URL_DEB
