#!/bin/sh

PKGNAME=grok-bot
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Grok Bot - AI teammates with their own cloud computers from xAI"
URL="https://x.ai/bot"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info --arch-arch)"

case "$(epm print info -p)" in
    rpm)
        field=rpmUrl
        ;;
    *)
        field=debUrl
        ;;
esac

PKGURL="$(get_json_value "https://api2.cursor.sh/updates/api/download/stable/linux-$arch/sand" "$field")"

install_pkgurl
