#!/bin/sh

PKGNAME=pycharm-community
SUPPORTEDARCHES="x86_64"
DESCRIPTION="PyCharm CE — The Python IDE for Professional Developers"

. $(dirname $0)/common.sh

URL=$(epm tool eget -O- "https://data.services.jetbrains.com/products/releases?code=PCC&latest=true&type=release" | epm --inscript tool json -b | grep '"PCC",0,"downloads","linux","link"' | sed -e 's|.*[[:space:]]||')

#URL=https://download.jetbrains.com/python/pycharm-community-2022.2.tar.gz

# eval for drop quotes
eval epm install $URL
