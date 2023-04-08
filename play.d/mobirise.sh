#!/bin/sh

PKGNAME=mobirise
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Mobirise - create awesome mobile-friendly websites!"

. $(dirname $0)/common.sh

# https://mobihtml.ru/
epm install "https://download.mobirise.com/MobiriseSetup.deb"

