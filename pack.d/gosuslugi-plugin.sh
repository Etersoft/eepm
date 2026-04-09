#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION=$3

. $(dirname $0)/common.sh

__get_deb_from_sh() {
    payload_offset=$(grep --text --line-number '^PAYLOAD:$' "$1" | cut -d: -f1)
    tail -n +$((payload_offset + 1)) "$1" | tar -xC "."
}

case "$TAR" in
    *.zip)
        # Gosplugin_Linux-Debian_Installer.deb.zip contains Gosplugin_Linux-Debian_Installer.deb.sh
        unzip -j "$TAR" '*.sh' || fatal
        INSTALLER=$(ls Gosplugin_Linux-Debian_Installer.deb.sh 2>/dev/null) || fatal 'installer not found in zip'
        __get_deb_from_sh "$INSTALLER"
        rm -f "$INSTALLER"
        ;;
    *.sh)
        # Gosplugin_Linux-Debian_Installer.deb.sh
        __get_deb_from_sh "$TAR"
        ;;
    *)
        fatal "unknown archive format: $TAR"
        ;;
esac

BASENAME=$(basename gosuslugi-plugin*)

return_tar "$BASENAME"
