#!/bin/sh

FILENAME="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

echo "$(basename "$FILENAME")" | grep -q "^setup-full-8\.3.*-.*.run$" || fatal "run with file looks like setup-full-8.3.22.1851-x86_64.run"

INSTDIR="/opt/1cv8"
VERSION="$(echo $FILENAME | sed 's|.*-8|8|' | sed 's|-.*||')"
TARNAME="1c83-client-$VERSION.tar"

chmod -v u+x $FILENAME
# По умолчанию устанавливается только "client_full,langs,en,ru,advanced". Все остальные компоненты по умолчанию отключены.
# Задана тихая установка.
$SUDO $FILENAME --mode unattended || fatal "Can't install"

if echo "$FILENAME" | grep -q "x86_64.run$" ; then
    arch="x86_64"
elif echo "$FILENAME" | grep -q "i586.run$"; then
    arch="i586"
else
    fatal "Unsupported arch"
fi

# FIXME
UNINSTFILE=$INSTDIR/$arch/$VERSION/uninstaller-full
[ -s "$UNINSTFILE" ] || fatal "Can't detect $UNINSTFILE"

# 8.3.22.1851 -> 8*3*22*1851 (they use - in 1cv8-8.3.22-1851.desktop)
ADDFILES="/usr/share/applications/1cv8*$(echo $VERSION| sed -e 's|\.|*|g').desktop"

# FIXME: erc?
epm install --skip-installed tar || fatal
a= tar cf $TARNAME $INSTDIR $ADDFILES

# Задана тихая деинсталяция.
$SUDO $UNINSTFILE --mode unattended

return_tar $TARNAME
