#!/bin/sh

PKGNAME=gigatool
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="MultiTool: AI assistant for documents, spreadsheets, presentations and research"
URL="https://multitool.works/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case "$(epm print info -p)" in
    rpm) file=multitool-desktop-linux-x86_64.rpm ;;
    *) file=multitool-desktop-linux-amd64.deb ;;
esac

PKGURL="https://obs.ru-moscow-1.hc.sbercloud.ru/d-ssdev-crowd/function_descriptions/gigatool-electron/prod/$file"

install_pkgurl
