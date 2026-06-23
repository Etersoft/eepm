#!/bin/sh

PKGNAME=cups-pdf
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Virtual PDF printer for CUPS (PDF backend) from EPEL"
URL="https://www.cups-pdf.de/"

. $(dirname $0)/common.sh

# cups-pdf is missing in some RHEL-based repos (f.i. MSVSphere), install it from EPEL
EL="$(epm print info -r)"
case "$EL" in
    8|9|10) ;;
    *) EL="9" ;;
esac

arch="$(epm print info -a)"

PKGDIR="https://mirror.yandex.ru/epel/$EL/Everything/$arch/Packages/c"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(eget --list --latest "$PKGDIR/cups-pdf-*.el$EL.$arch.rpm") || fatal
else
    PKGURL=$(eget --list --latest "$PKGDIR/cups-pdf-$VERSION-*.el$EL.$arch.rpm") || fatal
fi

if [ -n "$print_url" ] ; then
    echo "$PKGURL"
    exit 0
fi

# install with scripts: the postinstall creates the Cups-PDF printer queue via lpadmin
epm install --scripts "$PKGURL" || __suggest_ipfs_on_error

echo "Note: the Cups-PDF printer is created on install only when cups is running.
If you don't see the Cups-PDF printer, start cups and run:
# serv cups restart
# lpadmin -p Cups-PDF -v cups-pdf:/ -m CUPS-PDF_noopt.ppd -E
"
