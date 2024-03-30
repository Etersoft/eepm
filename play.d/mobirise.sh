#!/bin/sh

PKGNAME=mobirise
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Mobirise - create awesome mobile-friendly websites!"

. $(dirname $0)/common.sh

# https://mobihtml.ru/
epm install "https://download.mobirise.com/MobiriseSetup.deb"
warn_version_is_not_supported

