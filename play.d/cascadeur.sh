#!/bin/sh

PKGNAME=cascadeur
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Cascadeur - a physics‑based 3D animation software"

. $(dirname $0)/common.sh

# TODO: ask license, get version
epm pack --install $PKGNAME "https://cdn.cascadeur.com/builds/linux/59/cascadeur-linux.tgz" "2022.3.1"
