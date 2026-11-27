#!/bin/sh

PKGNAME=ideco-client
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Ideco Client (VPN/ZTNA client for Ideco NGFW) from the official site"
URL="https://docs.ideco.ru/"
TIPS="Run 'serv IdecoService on' to enable and start the Ideco Client service. Import the root certificate of your Ideco NGFW to the system if it uses a self-signed certificate."

. $(dirname $0)/common.sh

# only the latest installer is available
warn_version_is_not_supported

PKGURL="https://docs.ideco.ru/installers/v24/IdecoClient-install.sh"

install_pack_pkgurl || exit

serv IdecoService try-restart

serv --quiet IdecoService status >/dev/null && exit

echo
echo "Note: run
# serv IdecoService on
to start Ideco Client service
"
