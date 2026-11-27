#!/bin/sh

PKGNAME=ruclient
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="NIO-EUSB USB Hub Over Network client (ruhubt64) from the official site"
URL="https://nio-electronics.ru/ru/support.html"
TIPS="The console client works as the ruclient system service (run 'serv ruclient on'), control it with 'rhclientx86_64 -t \"HELP\"'. The GUI client is rhclt64 (run it as root)."

. $(dirname $0)/common.sh

BASEURL="https://archive.nio-electronics.ru/client/Linux"

if [ "$VERSION" = "*" ] ; then
    VERSION="$(fetch_url "https://archive.nio-electronics.ru/?dir=client/Linux" | grep -o 'href="?dir=client/Linux/[0-9][0-9.]*"' | sed -e 's|.*/||' -e 's|"$||' | sort -V | tail -n1)"
    [ -n "$VERSION" ] || fatal "Can't get the latest version from $BASEURL"
fi

# https://archive.nio-electronics.ru/client/Linux/6.0.3/RPM/ruclient-6.0.3-1.x86_64.rpm
# (repack.d/ruclient.sh adds the GUI client from $BASEURL/$VERSION/GUI/rhclt64)
PKGURL="$BASEURL/$VERSION/RPM/ruclient-$VERSION-1.x86_64.rpm"

install_pkgurl || exit

serv ruclient try-restart

serv --quiet ruclient status >/dev/null && exit

echo
echo "Note: run
# serv ruclient on
to enable and start NIO-EUSB client service (it needs the vhci-hcd kernel module),
or run GUI client with
$ sudo rhclt64
"
