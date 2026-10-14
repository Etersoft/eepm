#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. "$(dirname "$0")/common.sh"

erc --here "$TAR" || fatal 'Cannot extract Cisco Secure Client predeploy archive'

# The GUI package also contains the CLI. Installing vpn-cli as well conflicts
# with it; other modules are optional and are deliberately not selected.
set -- ./cisco-secure-client-vpn_*_amd64.deb
[ "$#" = 1 ] && [ -f "$1" ] || fatal 'Expected one Cisco Secure Client VPN package'
return_tar "$1"
