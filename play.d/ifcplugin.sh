#!/bin/sh

PKGNAME=ifcplugin
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="IFCPlugin (Gosuslugi portal browser plugin) from the official site"
URL="https://www.gosuslugi.ru/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://ds-plugin.gosuslugi.ru/plugin/upload/assets/distrib/IFCPlugin-x86_64.rpm"

install_pkgurl
