#!/bin/sh

PKGNAME=mtslink
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Ecosystem of services for business communications and collaboration'
URL="https://mts-link.ru/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://apps.webinar.ru/weteams/linkchats-desktop.deb"

install_pkgurl
