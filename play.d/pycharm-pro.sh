#!/bin/sh

PKGNAME=pycharm-professional
SUPPORTEDARCHES="x86_64"
DESCRIPTION="PyCharm Professional — The Python IDE for Professional Developers( Free 30-day trial available)"

. $(dirname $0)/common.sh

#URL="https://download.jetbrains.com/python/pycharm-professional-2022.2.1.tar.gz"
URL=$(epm tool eget -O- "https://data.services.jetbrains.com/products/releases?code=PCP&latest=true&type=release" | epm --inscript tool json -b | grep '"PCP",0,"downloads","linux","link"' | sed -e 's|.*[[:space:]]||' | sed -e 's|"||g')

epm install "$URL"
