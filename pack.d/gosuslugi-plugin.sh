#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION=$3

. $(dirname $0)/common.sh

__extract_payload_from_sh() {
    payload_offset=$(grep --text --line-number '^PAYLOAD:$' "$1" | cut -d: -f1)
    tail -n +$((payload_offset + 1)) "$1" | tar -xC "."
}

case "$TAR" in
    *.zip)
        # extract .sh installer from zip
        unzip -j "$TAR" '*.sh' || fatal
        INSTALLER=$(ls Gosplugin_*_Installer.*.sh 2>/dev/null | head -1) || fatal 'installer not found in zip'
        __extract_payload_from_sh "$INSTALLER"
        rm -f "$INSTALLER"
        ;;
    *.sh)
        __extract_payload_from_sh "$TAR"
        ;;
    *)
        fatal "unknown archive format: $TAR"
        ;;
esac

PKG=$(ls gosuslugi-plugin*.rpm gosuslugi-plugin*.deb 2>/dev/null | head -1)
[ -n "$PKG" ] || fatal 'gosuslugi-plugin package not found after extraction'

return_tar "$PKG"
