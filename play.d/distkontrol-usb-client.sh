#!/bin/sh

PKGNAME=distkontrol-usb-client
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="DistKontrolUSB Client (use USB devices over a network) from the official site"
URL="https://www.distkontrol.com/"
TIPS="Run 'sudo dkclt64' to use the GUI client (it needs root permissions), or run 'serv distkontrol-usb-client on' to start the console client as a service and control it with 'dkclient -t \"HELP\"'."

. $(dirname $0)/common.sh

# the vendor provides only the latest versionless binaries
warn_version_is_not_supported

case "$(epm print info -a)" in
    x86_64)
        # GUI client (the console client is downloaded by pack.d script additionally)
        PKGURL="https://www.distkontrol.com/upload/clients/linux/dkclt64"
        ;;
    aarch64)
        # console client only
        PKGURL="https://www.distkontrol.com/upload/clients/linux-console/dkclientarm64"
        ;;
esac

install_pack_pkgurl || exit

echo
echo "Note: run
# serv $PKGNAME on
to start DistKontrolUSB console client as a system service,
or run GUI client with
$ sudo dkclt64
"
