#!/bin/sh

PKGNAME=nsgclient
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Is the client software that allows access to corporate data and applications through Citrix ADC"
URL="https://www.citrix.com/downloads/citrix-gateway/plug-ins/Citrix-Gateway-VPN-EPA-Clients-Ubuntu.html"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="ipfs://QmXYsYw63ufk5aUmVpddA6YbjvAbdnnEZk36yGajU3pc5j?filename=Citrix_VPN.zip"

install_pack_pkgurl
