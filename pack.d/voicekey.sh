#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

# the vendor ships a single versionless "latest" binary; use its Last-Modified
# date (preserved as the file mtime by eget) as the package version
[ "$VERSION" = "*" ] && VERSION=""
[ -n "$VERSION" ] || VERSION="$(date -u -r "$TAR" +%Y.%m.%d 2>/dev/null)"
[ -n "$VERSION" ] || VERSION="0"

PKGNAME=$PRODUCT-$VERSION

# the download is a single raw ELF binary, not an archive
install -D -m755 "$TAR" usr/bin/voicekey || fatal

# let the 'input' group access /dev/uinput (global hotkey and auto-paste)
cat <<'EOF' | create_file usr/lib/udev/rules.d/99-voicekey-uinput.rules
KERNEL=="uinput", GROUP="input", MODE="0660"
EOF

# load the uinput module on boot (needed for the hotkey/auto-paste)
cat <<'EOF' | create_file usr/lib/modules-load.d/voicekey.conf
uinput
EOF

erc pack $PKGNAME.tar usr || fatal

# UPX-packed binary, so soname autodetection finds nothing: list deps explicitly
cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Sound
license: Proprietary
url: https://voicehotkey.com
summary: VoiceKey, voice typing triggered by a hotkey
description: VoiceKey records the microphone on a hotkey, transcribes the speech and pastes the recognized text into the active window.
requires: libgtk4 libalsa xdotool xclip fonts-ttf-google-noto-emoji-color
EOF

return_tar $PKGNAME.tar
