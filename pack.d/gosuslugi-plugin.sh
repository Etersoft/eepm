#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION=$3

. $(dirname $0)/common.sh

__get_deb_package() {
    payload_offset=$(grep --text --line-number '^PAYLOAD:$' $1 | cut -d: -f1)
    tail -n +$((payload_offset + 1)) $1 | tar -xC "."
}

__get_deb_package $TAR

# Gosplugin_Linux-Debian_Installer.deb.sh
BASENAME=$(basename gosuslugi-plugin* )

return_tar $BASENAME
