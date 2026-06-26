#!/bin/sh

PKGNAME=voicekey
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="VoiceKey - voice typing triggered by a hotkey"
URL="https://voicehotkey.com"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info -a)"
case "$arch" in
    x86_64)  variant="x86_64" ;;
    aarch64) variant="aarch64" ;;
    *) fatal "$arch is not supported" ;;
esac

# vendor ships a separate X11 and Wayland build; the X11 one also runs under
# Wayland via XWayland, so use it as the universal variant.
# Download from the Russia mirror: app.voicehotkey.com is blocked in Russia.
PKGURL="https://ru.voicehotkey.com/releases/ubuntu/$variant/voicekey"

install_pack_pkgurl

echo
echo 'Note: for global hotkey support add your user to the "input" group:
    sudo usermod -aG input $USER
and re-login.'
