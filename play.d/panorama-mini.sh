#!/bin/sh

PKGNAME=panorama-mini
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="GIS Panorama Mini (geographic information system) from the official site"
URL="https://gisinfo.net/download/download_linux.htm"
TIPS="Without a Guardant Sign USB key the program works in demo mode (one-sheet maps up to 8000 objects). For multi-sheet maps raise the open files limit ('* hard nofile 65536' and '* soft nofile 65536' in /etc/security/limits.conf)."

. $(dirname $0)/common.sh

# the vendor provides only the latest versionless archive
warn_version_is_not_supported

case "$(epm print info -e)" in
    RedOS/*)
        build="x64.red7.3"
        ;;
    AlterOS/*)
        build="x64.alteros2025"
        ;;
    AstraLinux*)
        build="x64.astrase"
        ;;
    *)
        case "$(epm print info -p)" in
            rpm)
                build="x64.alt10"
                ;;
            *)
                build="x64.ubuntu20"
                ;;
        esac
        ;;
esac

PKGURL="https://gistoolkit.com/download/panmini15.$build.zip"

install_pack_pkgurl

echo
echo "$TIPS"
