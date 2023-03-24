#!/bin/sh

PKGNAME=jetbrains-toolbox
SUPPORTEDARCHES="x86_64"
DESCRIPTION="JetBrains Toolbox App from the official site"

. $(dirname $0)/common.sh

# https://github.com/nagygergo/jetbrains-toolbox-install/blob/master/jetbrains-toolbox.sh

URL=$(epm tool eget -O- "https://data.services.jetbrains.com/products?code=TBA&release.type=eap%2Crc%2Crelease&fields=distributions%2Clink%2Cname%2Creleases" | epm --inscript tool json -b | grep '0,"releases",0,"downloads","linux","link"' | sed -e 's|.*[[:space:]]||')

#https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.25.12627.tar.gz

# eval for drop quotes
eval epm pack --install $PKGNAME $URL

echo
echo "Run jetbrains-toolbox under user to install."

#if [ ! -r /dev/fuse ] ; then
#    echo
#    echo "Add the user $USER to fuse group"
#    echo "For example. run # usermod -aG fuse $USER"
#fi
